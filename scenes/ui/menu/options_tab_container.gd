extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	var tab_count = self.get_tab_count()
	for i in range(tab_count):
		var tab_title = self.get_tab_title(i)
		var split_positions := self._get_split_positions(tab_title)
		
		var words := PackedStringArray()
		var start_position := 0
		for split_position in split_positions:
			words.push_back(tab_title.substr(start_position, split_position - start_position))
			start_position = split_position
		# Handle the case where no splits found or the last element needs to be added (split_pos -> the end)
		words.push_back(tab_title.substr(start_position, -1))
		
		self.set_tab_title(i, " ".join(words))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _get_split_positions(words: String) -> Array[int]:
	var split_positions: Array[int] = []
	for i in range(1, words.length()):
		var char_ascii_number = words.unicode_at(i)
		if char_ascii_number >= 65 and char_ascii_number <= 90: # Is capitalized character?
			split_positions.push_back(i)
	return split_positions
