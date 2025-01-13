extends PanelContainer

@onready var chat_history: VBoxContainer = $MarginContainer/ScrollContainer/ChatHistory

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func add_text_element(author: String, text: String):
	var element = TextElement.new(author, text)
	element.set_name("TextElement")
	chat_history.add_child(element)
	
func clear_text_elements():
	for child in chat_history.get_children():
		child.queue_free()
