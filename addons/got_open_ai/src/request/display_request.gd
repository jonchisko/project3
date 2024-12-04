extends OpenAiRequestBase

class_name DisplayRequest

func request_data(url: String, headers: PackedStringArray, method: HTTPClient.Method, request_data: Dictionary) -> String:
	print(JSON.stringify(request_data))
	return ""
