extends Node2D

@onready var parallax_background: ParallaxBackground = $CanvasLayer/ParallaxBackground
@onready var end_story_text: Label = %EndStoryText
@onready var continue_label: Label = %ContinueLabel

@export_multiline var end_texts_landing_failure: Array[String]
@export_multiline var end_texts_landing_success: Array[String]

var _correct_texts: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._set_correct_text()
	var current_text = self._correct_texts.pop_front()
	self.end_story_text.text = current_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.parallax_background.scroll_offset -= Vector2(20, 0) * delta


func _input(event: InputEvent) -> void:
	var event_key = event as InputEventKey
	if event_key != null and event_key.keycode == KEY_SPACE and event.is_pressed() and not event_key.echo:
		if self._correct_texts.is_empty():
			self.get_tree().change_scene_to_file("res://scenes/ui/menu/main_menu_scene.tscn")
			return
		var current_text = self._correct_texts.pop_front()
		self.end_story_text.text = current_text


func _set_correct_text() -> void:
	if QuestManager.current_secondary_quests_completed == QuestManager.all_secondary_quests:
		self._correct_texts = self.end_texts_landing_success
	else:
		self._correct_texts = self.end_texts_landing_failure
