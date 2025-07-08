extends Node

@onready var logger_rust: ProjectLogger = $LoggerRust

enum LogType {
	GameEvent,
	Dialogue,
	Other,
}

func _ready():
	self.logger_rust.push_message("Test")
	self.logger_rust.push_message("Testasdasd !")
	self.logger_rust.test_method(LogType.GameEvent)
	
	
func _process(delta):
	pass
