use crate::constants;
use std::fmt::Display;

use godot::{classes::file_access::ModeFlags, prelude::*};

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
        let log_file = GFile::open(constants::USER_LOG_FILE_PATH, ModeFlags::WRITE);

        if let Err(error) = log_file {
            godot_error!(
                "Could not save the log file to user log file path! Error: {}",
                error
            );
            return;
        }

        let mut log_file = log_file.unwrap();

        for element in &self.messages {
            let line = format!(
                "{}\n------------------------------------------------------------\n",
                *element.bind()
            );

            log_file.write_gstring(&line).unwrap();
        }
    }
}
