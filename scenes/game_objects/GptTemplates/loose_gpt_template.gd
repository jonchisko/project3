extends BaseGptTemplate
class_name LooseGptTemplate


func add_instructions(gpt_template: TemplateBase) -> void:
	gpt_template.append_message("developer", "# Instructions
The list of instructions under which you operate:
-  Stay in character and do not mention you being an AI.")
