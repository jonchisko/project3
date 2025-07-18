use crate::file_storage::FileStorage;

use std::fmt::Display;

use godot::{meta::AsArg, prelude::*};

#[derive(GodotConvert, Debug)]
#[godot(via = i64)]
pub enum LogType {
    GameEvent,
    Dialogue,
    Other,
}

impl Display for LogType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let enum_display = match self {
            LogType::GameEvent => "GAME_EVENT",
            LogType::Dialogue => "DIALOGUE",
            LogType::Other => "OTHER",
        };

        f.pad(enum_display)
    }
}

#[derive(GodotClass)]
#[class(no_init)]
pub struct LogMessage {
    log_type: LogType,
    source: String,
    content: String,
}

#[godot_api]
impl LogMessage {
    #[func]
    fn create(log_type: LogType, source: String, content: String) -> Gd<Self> {
        Gd::from_object(Self {
            log_type,
            source,
            content,
        })
    }
}

impl Display for LogMessage {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "|| {:^15} | {:^15} ||\n\n{}\n",
            self.log_type, self.source, self.content
        )
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
pub struct ProjectLogger {
    messages: Vec<Gd<LogMessage>>,
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
    fn push_message(&mut self, message: Gd<LogMessage>) {
        self.messages.push(message);
    }

    #[func]
    fn clear_messages(&mut self) {
        self.messages.clear();
    }

    #[func]
    fn pop_last_message(&mut self) -> bool {
        if self.messages.is_empty() {
            return false;
        }

        self.messages.pop();

        true
    }

    #[func]
    fn save_to_file_blocking(&self) {
        let mut data = String::from("");
        for element in &self.messages {
            data.push_str(&*element.bind().to_string());
            data.push_str("\n------------------------------------------------------------\n");
        }

        if let Err(msg) = FileStorage::save(&data) {
            godot_error!("{}", msg);
        }
    }
}

pub enum RepositoryError {
    StorageFileOpen(String),
    WriteString(String),
}

impl Display for RepositoryError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let message = match self {
            RepositoryError::StorageFileOpen(message) => {
                format!("File create/open issue: {}", message)
            }
            RepositoryError::WriteString(message) => format!("String write issue: {}", message),
        };

        f.pad(&message)
    }
}

pub trait Repository {
    fn save<T>(data: T) -> Result<(), RepositoryError>
    where
        T: AsArg<GString>;
}
