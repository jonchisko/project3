extends Node


var project_logger: ProjectLogger


enum LogType {
	GameEvent,
	Dialogue,
	Other,
}


func _ready():
	self.project_logger = self.get_node("./ProjectLogger") as ProjectLogger
	self._log_info(LogType.GameEvent, "s1", "lol")
	self._log_info(LogType.GameEvent, "s1", "lol")
	self._log_info(LogType.Other, "s2", "lol")
	self._log_info(LogType.Dialogue, "s1", "lol")
	self.project_logger.save_to_file_blocking()

func _enter_tree() -> void:
	GameEvents.log_info.connect(self._log_info)
	
	
func _exit_tree() -> void:
	self._log_info(LogType.Other, "s22", "lol2222")
	self.project_logger.save_to_file_blocking()
	self._log_info(LogType.Other, "asdasd", "!!!!!!!!!!!!!!")
	self.project_logger.save_to_file_blocking()
	GameEvents.log_info.disconnect(self._log_info)


func _log_info(log_type: LogType, source: String, content: String) -> void:
	var message = LogMessage.create(log_type, source, content)
	self.project_logger.push_message(message)
