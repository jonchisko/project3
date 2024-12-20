extends RefCounted

class_name LogProb

var token: String
var log: float
var bytes: Array

func _init(data: Dictionary):
	self.token = data["token"]
	self.log = data["logprob"]
	self.bytes = data["bytes"]
	
func _process_data(data: Dictionary) -> Array:
	if not data.has("bytes") or data["bytes"] == null:
		return []
	
	return data["bytes"]
