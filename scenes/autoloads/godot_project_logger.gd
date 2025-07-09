extends Node


var project_logger: ProjectLogger


enum LogType {
	GameEvent,
	Dialogue,
	Other,
}


func _ready():
	self.project_logger = self.get_node("./ProjectLogger") as ProjectLogger


func _enter_tree() -> void:
	GameEvents.log_info.connect(self._log_info)
	
	
func _exit_tree() -> void:
	self.project_logger.save_to_file_blocking()
	GameEvents.log_info.disconnect(self._log_info)


func save_to_file_blocking() -> void:
	self.project_logger.save_to_file_blocking()


func _log_info(log_type: LogType, source: String, content: String) -> void:
	var message = LogMessage.create(log_type, source, content)
	self.project_logger.push_message(message)
