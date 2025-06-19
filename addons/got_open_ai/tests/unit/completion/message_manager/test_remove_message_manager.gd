extends GutTest

func test_remove_newest_on_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.remove_newest_message()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be 0, but is not.")
	
func test_remove_newest_on_non_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	object_under_test.append_message("test", "oldest")
	object_under_test.append_message("test", "newest")
	
	# Act
	object_under_test.remove_newest_message()
	
	# Act
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be 1, but is not.")
	assert_eq(object_under_test.get_combined_message_data()[0]["content"].contains("oldest"), true)
	
func test_remove_oldest_on_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.remove_oldest_message()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be 0, but is not.")
	
func test_remove_oldest_on_non_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	object_under_test.append_message("test", "oldest")
	object_under_test.append_message("test", "newest")
	
	# Act
	object_under_test.remove_oldest_message()
	
	# Act
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be 1, but is not.")
	assert_eq(object_under_test.get_combined_message_data()[0]["content"].contains("newest"), true)
	
func test_remove_combination() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	object_under_test.append_message("test", "oldest")
	object_under_test.append_message("test", "middle")
	object_under_test.append_message("test", "newest")
	
	# Act
	object_under_test.remove_oldest_message()
	object_under_test.remove_newest_message()
	
	# Act
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be 1, but is not.")
	assert_eq(object_under_test.get_combined_message_data()[0]["content"].contains("middle"), true)
	
func test_remove_combination_with() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	object_under_test.append_message_with(MessageBuilder.new("test").with_content("oldest").build())
	object_under_test.append_message_with(MessageBuilder.new("test").with_content("middle").build())
	object_under_test.append_message_with(MessageBuilder.new("test").with_content("newest").build())
	
	# Act
	object_under_test.remove_oldest_message()
	object_under_test.remove_newest_message()
	
	# Act
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be 1, but is not.")
	assert_eq(object_under_test.get_combined_message_data()[0].content.contains("middle"), true)
