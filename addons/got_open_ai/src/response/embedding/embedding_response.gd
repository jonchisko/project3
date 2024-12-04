extends RefCounted

class_name EmbeddingResponse

var _successful: bool = false
var _index: int = 0
var _emebdding: Array = []
var _prompt_tokens: int = 0
var _total_tokens: int = 0

func successful() -> bool:
	return self._successful
	
func index() -> int:
	return self._index

func embedding() -> Array:
	return self._emebdding
	
func prompt_tokens() -> int:
	return self._prompt_tokens

func total_tokens() -> int:
	return self._total_tokens

func _init(successful: bool, index: int = 0, embedding: Array = [], prompt_tokens: int = 0, total_tokens: int = 0):
	self._successful = successful
	self._index = index
	self._emebdding = embedding
	self._prompt_tokens = prompt_tokens
	self._total_tokens = total_tokens
