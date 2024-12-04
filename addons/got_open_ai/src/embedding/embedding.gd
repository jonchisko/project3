extends RefCounted

class_name Embedding


var _configuration: ApiConfiguration
var _open_ai_request: OpenAiRequestBase

var _model: String = "gpt-3.5-turbo"
var _encoding_format: String = "float"

func _init(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase, model: String, encoding_format: String):
	self._configuration = configuration
	self._open_ai_request = open_ai_request
	self._model = model
	self._encoding_format = encoding_format

func get_embedding(text: String) -> EmbeddingResponse:
	
	var response: EmbeddingResponse = await ResponseFactory.GetEmbeddingResponse(
		self._open_ai_request,
		self._configuration.url(),
		self._configuration.get_content_authorization_header(), 
		self._configuration.method(), 
		self._create_request_data(text))
	
	return response
	
func _create_request_data(text: String) -> Dictionary:
	var data: Dictionary = {}
	data["model"] = self._model
	data["encoding_format"] = self._encoding_format
	data["input"] = text
	
	return data
