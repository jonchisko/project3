extends RefCounted

class_name UserConfiguration

var _api_key: String
# TODO
# think about adding project and organization

func _init(api_key: String):
	self._api_key = api_key
	
func api_key() -> String:
	return self._api_key
