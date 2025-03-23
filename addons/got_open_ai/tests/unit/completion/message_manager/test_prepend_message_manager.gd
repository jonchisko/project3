extends GutTest

func test_prepend_message_on_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.prepend_message("test", "message")
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be 1, but is not.")
	assert_eq(object_under_test.messages_to_string().contains("message"), true)
	
	
func test_prepend_messages_on_non_empty_messages_expect_order_reversed() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	var messages: Array[String] = ["message_1", "message_2", "message_3"]
	
	# Act
	for message in messages:
		object_under_test.prepend_message("test", message)
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), messages.size(), "Size should be '{size_key}', but it is not.".format({"size_key": messages.size()}))
	
	var message_data = object_under_test.get_combined_message_data()
	for index in message_data.size():
		assert_eq(message_data[index]["content"], messages[messages.size() - index - 1])
		
func test_prepend_multiple_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	var messages: Array[Dictionary] = [{"test" : "test_message"}, {"system" : "system_message"}]
	
	# Act
	object_under_test.prepend_messages(messages)
	
	# Assert
	var combined_messages: Array[Dictionary] = object_under_test.get_combined_message_data()
	for index in messages.size():
		# messages.size() - index - 1 because we are in reverse due to prepending the elements and not appending
		var role_key = messages[messages.size() - index - 1].keys()[0]
		var expected_role = role_key
		var expected_message = messages[messages.size() - index - 1][role_key]
		assert_eq(combined_messages[index]["role"], expected_role)
		assert_eq(combined_messages[index]["content"], expected_message)

func test_prepend_message_dictionary() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.prepend_message_dictionary({"test": "test_message"})
	
	# Assert
	var combined_messages: Array[Dictionary] = object_under_test.get_combined_message_data()
	assert_eq(combined_messages[0]["role"], "test")
	assert_eq(combined_messages[0]["content"], "test_message")
