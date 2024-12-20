extends RefCounted

class_name TokenLogProb

var logprob: LogProb
var top_logprobs: Array[LogProb]

func _init(data: Dictionary):
	self.logprob = LogProb.new(data)
	self.top_logprobs = _get_top_logprobs(data)
	
func _get_top_logprobs(data: Dictionary) -> Array[LogProb]:
	var top_logprobs: Array[LogProb] = []
	for top_logprob in data["top_logprobs"]:
		top_logprobs.push_back(LogProb.new(top_logprob))
	
	return top_logprobs
