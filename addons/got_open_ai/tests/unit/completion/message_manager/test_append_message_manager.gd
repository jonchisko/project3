extends GutTest

func test_append_message() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_message("test1", "message1")
	object_under_test.append_message("test2", "message2")
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 2, "Size should be two, but it is not.")
	assert_eq(object_under_test.messages_to_string().contains("message1"), true, "Messages do not contain 'message1'.")
	assert_eq(object_under_test.messages_to_string().contains("message2"), true, "Messages do not contain 'message2'.")
	assert_eq(object_under_test.messages_to_string().contains("message3"), false, "Messages contain 'message3'.")


func test_append_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_messages([{"role": "test1", "content": "message1"}, {"role": "test2", "content": "message2"}])
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 2, "Size should be two, but it is not.")
	assert_eq(object_under_test.messages_to_string().contains("message1"), true, "Messages do not contain 'message1'.")
	assert_eq(object_under_test.messages_to_string().contains("message2"), true, "Messages do not contain 'message2'.")
	assert_eq(object_under_test.messages_to_string().contains("message3"), false, "Messages contain 'message3'.")


func test_append_message_dictionary() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_message_dictionary({"role": "test", "content": "message"})
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be one, but it is not.")
	assert_eq(object_under_test.messages_to_string().contains("message"), true, "Messages do not contain 'message'.")


func test_append_messages_combined_variations() -> void:
	# Arrange
	var expected_elements: Array[Dictionary] = [{"test1": "message1"}, {"test2": "message2"}, {"test3": "message3"}, {"test4": "message4"}]
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_message("test1", "message1")
	object_under_test.append_messages([{"role": "test2", "content": "message2"}, {"role": "test3", "content": "message3"}])
	object_under_test.append_message_dictionary({"role": "test4", "content": "message4"})
	
	# Assert
	var messages = object_under_test.messages_to_string()
	
	assert_eq(object_under_test.get_combined_message_data().size(), expected_elements.size(), 
	"Size should be {size}, but it is not.".format({"size": expected_elements.size()}))
	for expected_element in expected_elements:
		assert_eq(messages.contains(expected_element.values()[0]), true, "Messages do not contain '{msg}'.".format({"msg": expected_element.values()[0]}))
		assert_eq(messages.contains(expected_element.keys()[0]), true, "Messages do not contain '{key}'.".format({"key": expected_element.keys()[0]}))


func test_append_static_context() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_static_context("test1", "message1")
	object_under_test.append_static_context("test2", "message2")
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 2, "Size should be two, but it is not.")
	assert_eq(object_under_test.context_to_string().contains("message1"), true, "Messages do not contain 'message1'.")
	assert_eq(object_under_test.context_to_string().contains("message2"), true, "Messages do not contain 'message2'.")
	assert_eq(object_under_test.context_to_string().contains("message3"), false, "Messages contain 'message3'.")
	

func test_append_static_contexts() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_static_contexts([{"role": "test1", "content": "message1"}, {"role": "test2", "content": "message2"}])
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 2, "Size should be two, but it is not.")
	assert_eq(object_under_test.context_to_string().contains("message1"), true, "Messages do not contain 'message1'.")
	assert_eq(object_under_test.context_to_string().contains("message2"), true, "Messages do not contain 'message2'.")
	

func test_append_static_context_dictionary() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.append_static_context_dictionary({"role": "test1", "content": "message1"})
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be one, but it is not.")
	assert_eq(object_under_test.context_to_string().contains("test1"), true, "Messages do not contain 'test1'.")
	assert_eq(object_under_test.context_to_string().contains("message1"), true, "Messages do not contain 'message1'.")
