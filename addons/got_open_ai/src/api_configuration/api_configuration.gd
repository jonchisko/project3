extends RefCounted

class_name ApiConfiguration

const _content_type: String = "Content-Type: application/json"
const _authorization_bearer: String = "Authorization: Bearer {key}"

var _url: String
var _user_configuration: UserConfiguration
var _method: HTTPClient.Method = HTTPClient.METHOD_POST

func _init(url: String, user_configuration: UserConfiguration, method: HTTPClient.Method):
	self._url = url
	self._user_configuration = user_configuration
	self._method = method

func url() -> String:
	return self._url
	
func content_type() -> String:
	return self._content_type
	
func authorization_bearer() -> String:
	return self._authorization_bearer.format({"key": self._user_configuration.api_key()})
	
func get_content_authorization_header() -> PackedStringArray:
	return PackedStringArray([
		content_type(), 
		authorization_bearer()
	])

func method() -> HTTPClient.Method:
	return self._method
