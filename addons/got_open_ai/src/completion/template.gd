extends TemplateBase

class_name Template

var _model: String
var _temperature: float
var _frequency_penalty: float
var _presence_penalty: float
var _log_probs: bool = false
var _max_completion_tokens: int
var _n_choices: int
var _tools: Array[Dictionary]
var _tool_choice: String
var _stop: Array[String]
var _response_format: String
var _stream: bool

func _init(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase, message_manager: MessageManager, model: String, temperature: float, frequency_penalty: float,
presence_penalty: float, log_probs: bool, max_completion_tokens: int, n_choices: int,
tools: Array[Dictionary], tool_choice: String, stop: Array[String], response_format: String, stream: bool):
	super(configuration, open_ai_request, message_manager)
	self._model = model
	self._temperature = temperature
	self._frequency_penalty = frequency_penalty
	self._presence_penalty = presence_penalty
	self._log_probs = log_probs
	self._max_completion_tokens = max_completion_tokens
	self._n_choices = n_choices
	self._tools = tools
	self._tool_choice = tool_choice
	self._stop = stop
	self._response_format = response_format
	self._stream = stream


func construct_data() -> Dictionary:
	var data: Dictionary = {}
	
	data["model"] = self._model
	data["temperature"] = self._temperature
	data["frequency_penalty"] = self._frequency_penalty
	data["presence_penalty"] = self._presence_penalty
	data["logprobs"] = self._log_probs
	
	data["n"] = self._n_choices
	data["stream"] = self._stream
	
	if not self._tool_choice.is_empty():
		data["tool_choice"] = self._tool_choice
	if self._max_completion_tokens >= 0:
		data["max_completion_tokens"] = self._max_completion_tokens
	if self._tools.size() > 0:
		data["tools"] = self._tools
		data["tool_choice"] = self._tool_choice
	if self._stop.size() > 0:
		data["stop"] = self._stop
	if not self._response_format.is_empty():
		data["response_format"] = self._response_format
	
	return data
