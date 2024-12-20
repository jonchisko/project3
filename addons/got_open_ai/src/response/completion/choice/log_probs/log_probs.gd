extends RefCounted

class_name LogProbs

var content: Array[TokenLogProb]
var refusal: Array[TokenLogProb]

func _init(data: Dictionary):
	self.content = self._process_token_problogs(data, "content")
	self.refusal = self._process_token_problogs(data, "refusal")
	
func _process_token_problogs(data: Dictionary, key: String) -> Array[TokenLogProb]:
	var token_problogs: Array[TokenLogProb] = []
	
	if data[key] == null or data[key].size() == 0:
		return token_problogs
	
	for token in data[key]:
		token_problogs.push_back(TokenLogProb.new(token))
		
	return token_problogs
