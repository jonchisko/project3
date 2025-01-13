extends PanelContainer

class_name TextElement

@onready var AuthorTitle: RichTextLabel = $MarginContainer/VBoxContainer/AuthorTitle
@onready var AuthorText: RichTextLabel = $MarginContainer/VBoxContainer/AuthorMessage

func _init(author: String, text: String):
	print("Text element creeated")
	AuthorTitle.text = author
	AuthorText.text = text
