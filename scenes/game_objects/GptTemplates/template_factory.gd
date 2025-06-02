extends Node
class_name TemplateFactory

@export var templates: Array[BaseGptTemplate]

func get_template(template_type: OpenAiTypes.TemplateType) -> BaseGptTemplate:
	match template_type:
		OpenAiTypes.TemplateType.Strict:
			print("TemplateFactory: creating strict template")
			return templates[0]
		OpenAiTypes.TemplateType.Loose:
			print("TemplateFactory: creating loose template")
			return templates[1]
		_:
			printerr("TemplateFactory: type doesnt exist! Returning default Loose type")
			return templates[1]
