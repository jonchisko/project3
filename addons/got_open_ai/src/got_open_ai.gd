extends Node

class_name GotOpenAi

var user_configuration: UserConfiguration

func GetPreviewCompletion() -> Completion:
	var api_configuration: ApiConfiguration = ApiConfigurationFactory.get_completion_configuration(UserConfiguration.new("api_key"))
	return Completion.new(api_configuration, DisplayRequest.new(), MessageManager.new())
	
func GetGptCompletion() -> Completion:
	if user_configuration == null:
		printerr("User configuration is null. Set user configuration before requesting GptCompletion object.")
	var api_configuration: ApiConfiguration = ApiConfigurationFactory.get_completion_configuration(user_configuration)
	
	var open_ai_request = OpenAiRequest.new()
	add_child(open_ai_request)
	return Completion.new(api_configuration, open_ai_request, MessageManager.new())

func _ready() -> void:
	print("Start init node of GotOpenAi")
