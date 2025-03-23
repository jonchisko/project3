extends RefCounted

class_name ResponseFactory

static func GetCompletionResponse(requester: OpenAiRequestBase, url: String, headers: PackedStringArray, method: HTTPClient.Method, request_data: Dictionary) -> CompletionResponse:
	var response_data: String = await requester.request_data(url, headers, method, request_data)
	
	if response_data == null or response_data.is_empty():
		printerr("Response data is null or empty.")
		return CompletionResponse.new(false, [], 0, 0, 0, {})
	# print(response_data)
	
	var dictionary: Dictionary = JSON.parse_string(response_data)
	
	if dictionary.has("error"):
		var error_message = "Error was returned. Message: {message}."
		if dictionary["error"].has("message"):
			error_message = error_message.format({"message": dictionary["error"]["message"]})
		else:
			error_message = error_message.format({"message": "none given"})
		printerr(error_message)
		return CompletionResponse.new(false, [], 0, 0, 0, {})
	
	var choices = dictionary["choices"]
	var prompt_tokens = dictionary["usage"]["prompt_tokens"]
	var completion_tokens = dictionary["usage"]["completion_tokens"]
	var total_tokens = dictionary["usage"]["total_tokens"]
	var completion_tokens_details = dictionary["usage"]["completion_tokens_details"]
	
	return CompletionResponse.new(true, choices, prompt_tokens, completion_tokens, total_tokens, completion_tokens_details)
	
static func GetEmbeddingResponse(requester: OpenAiRequestBase, url: String, headers: PackedStringArray, method: HTTPClient.Method, request_data: Dictionary) -> EmbeddingResponse:
	var response_data: String = await requester.request_data(url, headers, method, request_data)
	
	if response_data == null or response_data.is_empty():
		return EmbeddingResponse.new(false, 0, [], 0, 0)
	
	var dictionary = JSON.parse_string(response_data)
	
	var index = dictionary["data"][0]["index"]
	var embedding = dictionary["data"][0]["embedding"]
	var prompt_tokens = dictionary["usage"]["prompt_tokens"]
	var total_tokens = dictionary["usage"]["total_tokens"]
	
	return EmbeddingResponse.new(true, index, embedding, prompt_tokens, total_tokens)
