extends RefCounted

class_name CompletionResponse

var _successful: bool = false
var _choices: Array[ChoiceResponse]
var _prompt_tokens: int = 0
var _completion_tokens: int = 0
var _total_tokens: int = 0
var _completion_tokens_details: Dictionary = {}

func successful() -> bool:
	return self._successful

func choices() -> Array:
	return self._choices
	
func prompt_tokens() -> int:
	return self._prompt_tokens
	
func completion_tokens() -> int:
	return self._completion_tokens
	
func total_tokens() -> int:
	return self._total_tokens
	
func completion_tokens_details() -> Dictionary:
	return self._completion_tokens_details

func _init(successful: bool, choices: Array, prompt_tokens: int = 0, completion_tokens: int = 0, total_tokens: int = 0, completion_tokens_details: Dictionary = {}) -> void:
	self._successful = successful
	self._choices = _process_choices(choices)
	self._prompt_tokens = prompt_tokens
	self._completion_tokens = completion_tokens
	self._total_tokens = total_tokens
	self._completion_tokens_details = completion_tokens_details
	
func _process_choices(choices: Array) -> Array[ChoiceResponse]:
	var choice_responses: Array[ChoiceResponse] = []
	for choice in choices:
		choice_responses.push_back(ChoiceResponse.new(choice))
	
	return choice_responses
