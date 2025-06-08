extends Node


var open_ai_api_key: String = ""
var open_ai_model: OpenAiTypes.ModelVersion
var template_type: OpenAiTypes.TemplateType

var temperature: float = 0.5:
	set(value):
		temperature = clampf(value, 0.0, 1.0)
		
var frequency_penalty: float = 0.0:
	set(value):
		frequency_penalty = clampf(value, -2.0, 2.0)

var history_max_last_exchanges: int = 5:
	set(value):
		history_max_last_exchanges = clamp(value, 1, 10)
		
var history_max_similar_results: int = 10:
	set(value):
		history_max_similar_results = clamp(value, 1, 20)
		
var history_threshold_similar_results: float = 0.6:
	set(value):
		history_threshold_similar_results = clampf(value, 0.0, 1.0)
