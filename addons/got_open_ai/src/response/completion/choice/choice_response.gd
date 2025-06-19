extends RefCounted

class_name ChoiceResponse

var index: int
var message: Message
var log_probs: LogProbs
var finish_reason: String

func _init(data: Dictionary):
	self.index = data["index"]
	self.message = self._create_message(data["message"])
	self.log_probs = self._process_log_probs(data)
	self.finish_reason = data["finish_reason"]

func _process_log_probs(data: Dictionary) -> LogProbs:
	if not data.has("logprobs") or data["logprobs"] == null:
		return null
	return LogProbs.new(data["logprobs"])

func _create_message(data: Dictionary) -> Message:
	var message_builder: MessageBuilder = MessageBuilder.new(data["role"])
	return message_builder.build_from_dict(data)
