extends Control
class_name OptionsMenu


signal options_closed


@onready var _master_slider = %MasterSlider
@onready var _sfx_slider = %SfxSlider
@onready var _game_music_slider = %GameMusicSlider
@onready var _menu_music_slider = %MenuMusicSlider
@onready var _screen_mode_button = %ScreenModeButton
@onready var open_ai_api_text_edit = %OpenAiApiTextEdit
@onready var gpt_template_button: OptionButton = %GptTemplateButton


const _WINDOW_ID: int = 0


func _ready():
	self.modulate = Color.TRANSPARENT
	self._update_options()
	$AnimationPlayer.play("in")


func _update_options():
	self._set_display_button_text()
	
	(self._master_slider as Slider).value = self._get_volume_linear("Master")
	(self._sfx_slider as Slider).value = self._get_volume_linear("SFX")
	(self._game_music_slider as Slider).value = self._get_volume_linear("GameMusic")
	(self._menu_music_slider as Slider).value = self._get_volume_linear("MenuMusic")
	
	open_ai_api_text_edit.text = OpenAiConfiguration.open_ai_api_key
	gpt_template_button.select(self._from_template_type_to_index(OpenAiConfiguration.template_type))
	


func _on_tab_container_tab_clicked(tab):
	$AudioStreamPlayer.play()


func _on_main_menu_pressed():
	$AnimationPlayer.play("out_with_free")
	await $AnimationPlayer.animation_finished
	
	self.options_closed.emit()
	


func _on_screen_mode_button_pressed():
	var current_mode = DisplayServer.window_get_mode(self._WINDOW_ID)
	
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, self._WINDOW_ID)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false, self._WINDOW_ID)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, self._WINDOW_ID)

	self._set_display_button_text()


func _set_display_button_text():
	if DisplayServer.window_get_mode(self._WINDOW_ID) == DisplayServer.WINDOW_MODE_WINDOWED:
		(self._screen_mode_button as Button).text = "WINDOWED"
	else:
		(self._screen_mode_button as Button).text = "FULLSCREEN"


func _on_master_slider_value_changed(value):
	self._set_volume("Master", value)


func _on_sfx_slider_value_changed(value):
	self._set_volume("SFX", value)


func _on_game_music_slider_value_changed(value):
	self._set_volume("GameMusic", value)


func _on_menu_music_slider_value_changed(value):
	self._set_volume("MenuMusic", value)


func _set_volume(bus: String, volume_linear: float):
	var bus_index = AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_linear))


func _get_volume_linear(bus: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus)
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _on_open_ai_api_text_edit_text_submitted(new_text):
	OpenAiConfiguration.open_ai_api_key = new_text


func _on_gpt_template_button_item_selected(index: int) -> void:
	match gpt_template_button.get_item_text(index):
		"Strict":
			OpenAiConfiguration.template_type = OpenAiTypes.TemplateType.Strict
		"Loose":
			OpenAiConfiguration.template_type = OpenAiTypes.TemplateType.Loose


func _from_template_type_to_index(template_type: OpenAiTypes.TemplateType) -> int:
	match template_type:
		OpenAiTypes.TemplateType.Strict:
			return 0
		OpenAiTypes.TemplateType.Loose:
			return 1
		_:
			return 0
