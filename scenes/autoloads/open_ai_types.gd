extends Node

enum TemplateType {
	Loose,
	Strict
}

enum ModelVersion {
	Gpt_4_1,
	Gpt_4_1_Mini,
	Gpt_4_Turbo,
	Gpt_4o,
	Gpt_3_5_Turbo,
}


func model_version_to_string(model_version: ModelVersion) -> String:
	match model_version:
		ModelVersion.Gpt_4_1:
			return "gpt-4.1"
		ModelVersion.Gpt_4_1_Mini:
			return "gpt-4.1-mini"
		ModelVersion.Gpt_4_Turbo:
			return "gpt-4-turbo"
		ModelVersion.Gpt_4o:
			return "gpt-4o"
		ModelVersion.Gpt_3_5_Turbo:
			return "gpt-3.5-turbo"
		_:
			return "gpt-3.5-turbo"
