use std::{collections::HashMap, fmt::Display};

use godot::{
    builtin::{Array, Dictionary, GString},
    classes::{INode, Node},
    prelude::*,
};

use crate::{constants, file_storage::FileStorage, logging::Repository};

#[derive(GodotClass)]
#[class(base=Node)]
pub struct ChatHistoryRust {
    max_last_exchanges: i32,
    max_similar_results: i32,
    threshold_similar_results: f32,
    chat_history_service: Box<dyn ChatHistoryService>,
    base: Base<Node>,
}

#[godot_api]
impl INode for ChatHistoryRust {
    fn init(base: Base<Self::Base>) -> Self {
        Self {
            max_last_exchanges: 10,
            max_similar_results: 10,
            threshold_similar_results: 0.6,
            chat_history_service: Box::new(BasicHistoryService::new()),
            base: base,
        }
    }

    fn exit_tree(&mut self) {
        godot_print!("Saving history to file");
        self.save_history_to_file();
    }
}

#[godot_api]
impl ChatHistoryRust {
    #[func]
    fn set_max_last_exchanges(&mut self, value: i32) {
        self.max_last_exchanges = value.clamp(6, 30);
    }

    #[func]
    fn set_max_similar_results(&mut self, value: i32) {
        self.max_similar_results = value.clamp(1, 20);
    }

    #[func]
    fn set_threshold_similar_results(&mut self, value: f32) {
        self.threshold_similar_results = value.clamp(0.0, 1.0);
    }

    #[func]
    fn set_desired_history_service(&mut self) {
        self.chat_history_service = Box::new(BasicHistoryService::new());
    }

    #[func]
    fn save_conversation(&mut self, npc_id: GString, chat: VariantArray) {
        let mut messages = vec![];

        for message in chat.iter_shared() {
            let message_object = message.try_to::<Dictionary>().unwrap();
            let role = message_object.at("role").try_to::<GString>().unwrap();

            let content = message_object
                .get("content")
                .unwrap_or("".to_variant())
                .try_to::<GString>()
                .unwrap();

            let mut tools = vec![];
            let tool_calls = message_object.get("tool_calls");
            if tool_calls.is_some() {
                let tool_calls = tool_calls.unwrap().try_to::<VariantArray>().unwrap();

                for tool_call in tool_calls.iter_shared() {
                    let tool_call_object = tool_call.try_to::<Dictionary>().unwrap();
                    let tool_call_function = tool_call_object
                        .at("function")
                        .try_to::<Dictionary>()
                        .unwrap();

                    let tool_name = tool_call_function.at("name").try_to::<GString>().unwrap();
                    let tool_args = tool_call_function
                        .at("arguments")
                        .try_to::<GString>()
                        .unwrap();
                    let tool_info =
                        format!("Tool's name: {} | Tool's args: {}", tool_name, tool_args);

                    tools.push(tool_info);
                }
            }

            let mut message_builder = MessageBuilder::new(role.to_string(), content.to_string());
            if !tools.is_empty() {
                message_builder = message_builder.with_tools(tools);
            }

            messages.push(message_builder.build());
        }

        self.chat_history_service
            .update_history(npc_id.to_string(), messages);
    }

    #[func]
    fn get_summary(npc_id: GString) -> VariantArray {
        Array::new()
    }

    #[func]
    fn get_similar(npc_id: GString, query: GString) -> VariantArray {
        Array::new()
    }

    #[func]
    fn get_recent(&self, npc_id: GString) -> VariantArray {
        let all_history = self.get_history();

        let mut result: VariantArray = array![];
        if let Some(val) = all_history.get(npc_id) {
            result = val.try_to::<VariantArray>().unwrap();
        }

        result
    }

    #[func]
    fn get_history_data(&self) -> Dictionary {
        self.get_history()
    }

    #[func]
    fn set_history_data(&mut self, data: Dictionary) {
        let mut history_data = HashMap::new();

        for element in data.iter_shared() {
            let mut conversation = Vec::new();
            let npc_id = element.0.to_string();
            let messages = element.1.try_to::<VariantArray>().unwrap();

            for message in messages.iter_shared() {
                let message_data = message.try_to::<Dictionary>().unwrap();
                let mut message_builder = MessageBuilder::new(
                    message_data.at("author").to_string(),
                    message_data.at("content").to_string(),
                );
                let tool_calls = message_data.at("tool_calls").try_to::<GString>().unwrap();

                if tool_calls.eq(&GString::from("none")) {
                    conversation.push(message_builder.build());
                    continue;
                }

                message_builder = message_builder.with_tools(vec![]);
                conversation.push(message_builder.build());
            }

            history_data.insert(npc_id, conversation);
        }

        self.chat_history_service.set_all_data(history_data);
    }

    #[func]
    fn save_history_to_file(&self) {
        for (npc, history) in self.chat_history_service.get_all_data() {
            let file_name = format!("{}//{}.txt", constants::USER_HISTORY_NPC_FILE_PATH, npc);
            let data = history.iter().map(|message| message.to_string()).fold(
                String::new(),
                |mut acc, message| {
                    acc.push_str(&message[..]);
                    acc.push_str("\n");
                    acc
                },
            );

            if let Err(msg) = FileStorage::save(&file_name, &data) {
                godot_error!("{}", msg);
            }
        }
    }

    fn get_history(&self) -> Dictionary {
        let mut result: Dictionary = dict! {};
        let all_history = self.chat_history_service.get_all_data();

        for (npc_id, history) in all_history {
            let mut conversation: VariantArray = array![];

            for message in history {
                let mut tool_call_data = "none".to_string();

                if let Some(tool_calls) = &message.tool_calls {
                    tool_call_data = tool_calls.join(";");
                }

                let element = dict! {"author": message.author.to_variant(), "content": message.content.to_variant(), "tool_calls": tool_call_data.to_variant()};
                conversation.push(&element.to_variant());
            }

            result.set(npc_id.to_variant(), conversation);
        }

        result
    }
}

trait ChatHistoryService {
    fn get_history(&self, npc_id: String) -> Option<&Vec<Message>>;
    fn update_history(&mut self, npc_id: String, conversation: Vec<Message>);
    fn get_all_data(&self) -> &HashMap<String, Vec<Message>>;
    fn set_all_data(&mut self, data: HashMap<String, Vec<Message>>);
}

#[derive(Clone)]
struct Message {
    author: String,
    content: String,
    tool_calls: Option<Vec<String>>,
}

impl Message {
    fn new(author: String, content: String, tool_calls: Option<Vec<String>>) -> Self {
        Self {
            author,
            content,
            tool_calls,
        }
    }
}

impl Display for Message {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let display = format!(
            "|| {:^10} ||\n{}\n-------\nToolCalls: {:#?}\n\n\n",
            self.author,
            self.content,
            self.tool_calls.as_ref().unwrap_or(&vec![])
        );
        f.pad(&display)
    }
}

struct MessageBuilder {
    author: String,
    content: String,
    tool_calls: Option<Vec<String>>,
}

impl MessageBuilder {
    fn new(author: String, content: String) -> Self {
        Self {
            author,
            content,
            tool_calls: None,
        }
    }

    fn with_tools(mut self, tools: Vec<String>) -> Self {
        self.tool_calls = Some(tools);

        self
    }

    fn with_tool(mut self, tool: String) -> Self {
        if let None = self.tool_calls {
            self.tool_calls = Some(Vec::new());
        }

        self.tool_calls.as_mut().unwrap().push(tool);

        self
    }

    fn build(self) -> Message {
        Message::new(self.author, self.content, self.tool_calls)
    }
}

struct BasicHistoryService {
    history: HashMap<String, Vec<Message>>,
}

impl BasicHistoryService {
    fn new() -> Self {
        BasicHistoryService {
            history: HashMap::new(),
        }
    }
}

impl ChatHistoryService for BasicHistoryService {
    fn get_history(&self, npc_id: String) -> Option<&Vec<Message>> {
        self.history.get(&npc_id)
    }

    fn update_history(&mut self, npc_id: String, conversation: Vec<Message>) {
        self.history
            .entry(npc_id)
            .or_insert(vec![])
            .extend(conversation);
    }

    fn get_all_data(&self) -> &HashMap<String, Vec<Message>> {
        &self.history
    }

    fn set_all_data(&mut self, data: HashMap<String, Vec<Message>>) {
        self.history = data
    }
}
