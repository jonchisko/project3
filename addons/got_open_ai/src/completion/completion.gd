extends RefCounted

class_name Completion

var _configuration: ApiConfiguration
var _open_ai_request: OpenAiRequestBase
var _message_manager: MessageManager

const _max_n_choices: int = 10

var _model: String = "gpt-3.5-turbo"
var _temperature: float = 1.0
var _frequency_penalty: float = 0.0
var _presence_penalty: float = 0.0
var _log_probs: bool = false
var _max_completion_tokens: int = -1 # not viable
var _n_choices: int = 1
var _tools: Array[Dictionary] = []
var _tool_choice: String = ""
var _stop: Array[String] = []
var _response_format: String = "" 
var _stream: bool = false

func _init(configuration: ApiConfiguration, open_ai_request: OpenAiRequestBase, message_manager: MessageManager):
	self._configuration = configuration
	self._open_ai_request = open_ai_request
	self._message_manager = message_manager

func with_model(value: String) -> Completion:
	self._model = value
	return self

func with_temperature(value: float) -> Completion:
	self._temperature = clampf(value, 0.0, 2.0)
	return self

func with_frequency_penalty(value: float) -> Completion:
	self._frequency_penalty = clampf(value, -2.0, 2.0)
	return self

func with_presence_penalty(value: float) -> Completion:
	self._presence_penalty = clampf(value, -2.0, 2.0)
	return self
	
func with_log_probs(value: bool) -> Completion:
	self._log_probs = value
	return self 
	
func with_max_completion_tokens(value: int) -> Completion:
	self._max_completion_tokens = value
	return self
	
func with_n_choices(value: int) -> Completion:
	self._n_choices = clampf(value, 1, _max_n_choices)
	return self
	
func with_tool(value: Tool) -> Completion:
	if self._tool_choice.is_empty():
		self.with_auto_tool_choice()
	self._tools.append(value.get_tool_data())
	return self

func with_tools(values: Array[Tool]) -> Completion:
	if values.size() < 1:
		return self
	for value in values:
		self.with_tool(value)
	return self

func with_auto_tool_choice() -> Completion:
	self._tool_choice = "auto"
	return self
	
func with_no_tool_choice() -> Completion:
	self._tool_choice = "none"
	return self
	
func with_required_tool_choice() -> Completion:
	self._tool_choice = "required"
	return self

func with_stop_token(token: String) -> Completion:
	if self._stop.size() > 4:
		return self
	self._stop.append(token)
	return self

func with_response_format(value: String) -> Completion:
	if JSON.parse_string(value) != null:
		self._response_format = value
	return self

func with_stream(value: bool) -> Completion:
	self._stream = value
	return self

func get_template() -> TemplateBase: # here it could be possible to return either Template or StreamingTemplate -> think if interface needed
	return Template.new(self._configuration, self._open_ai_request, self._message_manager, 
	self._model, self._temperature, self._frequency_penalty,
	self._presence_penalty, self._log_probs, self._max_completion_tokens, self._n_choices, 
	self._tools, self._tool_choice, self._stop, self._response_format, self._stream)
