extends RefCounted

class_name ChoiceResponse

var index: int
var message: MessageResponse
var log_probs: LogProbs
var finish_reason: String

func _init(data: Dictionary):
	self.index = data["index"]
	self.message = MessageResponse.new(data["message"])
	self.log_probs = self._process_log_probs(data)
	self.finish_reason = data["finish_reason"]

func _process_log_probs(data: Dictionary) -> LogProbs:
	if not data.has("logprobs") or data["logprobs"] == null:
		return null
	return LogProbs.new(data["logprobs"])
