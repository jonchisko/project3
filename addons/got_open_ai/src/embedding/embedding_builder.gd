extends RefCounted

class_name EmbeddingBuilder


var _configuration: ApiConfiguration
var _open_ai_request: OpenAiRequestBase

var _model: String = "gpt-3"
var _encoding_format: String = "float"

static func new(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase) -> EmbeddingBuilder:
	return EmbeddingBuilder.new(configuration, open_ai_request)

func _init(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase) -> void:
	self._configuration = configuration
	self._open_ai_request = open_ai_request

func with_model(value: String) -> EmbeddingBuilder:
	self._model = value
	return self
	
func with_format(value: String) -> EmbeddingBuilder:
	match value:
		"float", "base64":
			self._encoding_format = value
		_:
			self._encoding_format = "float"
	return self
	
func build() -> Embedding:
	return Embedding.new(self._configuration, self._open_ai_request, self._model, self._encoding_format)
