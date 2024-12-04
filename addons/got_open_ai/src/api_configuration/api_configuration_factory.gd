extends RefCounted

class_name ApiConfigurationFactory

static func get_completion_configuration(user_configuration: UserConfiguration) -> ApiConfiguration:
	return ApiConfiguration.new("https://api.openai.com/v1/chat/completions",
	user_configuration,
	HTTPClient.METHOD_POST)
