extends Node2D


func _ready() -> void:
	GameEvents.level_change.emit(GameTypes.LevelChangeType.OnLoading)
