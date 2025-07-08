use std::io::Result;

use godot::prelude::*;

pub struct Content {
    pub source: String,
    pub info: String,
}

pub enum Message {
    GameEvent(Content),
    Dialogue(Content),
}

#[derive(GodotConvert, Debug)]
#[godot(via = i64)]
pub enum LogType {
	GameEvent,
	Dialogue,
	Other,
}



#[derive(GodotClass)]
#[class(base=Node)]
struct ProjectLogger {
    messages: Vec<String>,
    base: Base<Node>,
}

#[godot_api]
impl INode for ProjectLogger {
    fn init(base: Base<Self::Base>) -> Self {
        Self {
            messages: vec![],
            base: base,
        }
    }
}

#[godot_api]
impl ProjectLogger {
    #[func]
    fn push_message(&mut self, message: String) {
        godot_print!("PUSH MESSAGE");
        self.messages.push(message);
        godot_print!("Current state {}", self.messages[self.messages.len() - 1]);
    }

    #[func]
    fn test_method(&self, test: LogType) {
        match test {
            LogType::GameEvent => godot_print!("EARTH"),
            LogType::Dialogue => todo!(),
            LogType::Other => todo!(),
        }
    }

    fn clear_messages(&mut self) {
        todo!()
    }

    fn pop_last_message(&mut self) -> bool {
        //self.messages.pop()
        todo!()
    }

    fn save_to_file(&self) {
        todo!()
    }
}

/*
Godot -> autoload Logger

Logger.push_message(message_type: MessageType, source: String, info: String)
Logger.pop_message()
Logger.clear()
Logger.save_to_file()

Behind the scenes this autoload directyle delegates to the Rust Logger implementation
*/
