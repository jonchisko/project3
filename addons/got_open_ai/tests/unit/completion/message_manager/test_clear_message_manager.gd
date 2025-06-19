extends GutTest

#func before_each():
	#gut.p("ran setup", 2)

#func after_each():
	#gut.p("ran teardown", 2)
#
#func before_all():
	#gut.p("ran run setup", 2)
#
#func after_all():
	#gut.p("ran run teardown", 2)

func test_clear_all_messages_on_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.clear_all_messages()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be zero after clear, but it is not.")
	
	
func test_clear_all_messages_on_non_empty_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	object_under_test.append_message("test", "message_test")
	object_under_test.append_message_with(MessageBuilder.new("test").build())
	assert_eq(object_under_test.get_combined_message_data().size(), 2, "Size should be one after add, but it is not.")
	
	# Act
	object_under_test.clear_all_messages()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be zero after clear, but it is not.")
	

func test_clear_all_messages_should_not_clear_static_context() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	object_under_test.append_static_context("test", "message_test")
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be one after add, but it is not.")
	
	# Act
	object_under_test.clear_all_messages()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should still be one due to static context 
	not being cleared after clear of messages, but it is not.")
	

func test_clear_static_context_on_empty_static_context() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	
	# Act
	object_under_test.clear_static_context()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be zero after clear, but it is not.")	


func test_clear_static_context_on_non_empty_static_context() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	object_under_test.append_static_context("test", "message_test")
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be one after add, but it is not.")
	
	# Act
	object_under_test.clear_static_context()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 0, "Size should be zero after clear, but it is not.")	
	
	
func test_clear_static_context_should_not_clear_messages() -> void:
	# Arrange
	var object_under_test: MessageManager = MessageManager.new()
	object_under_test.append_message("test", "message_test")
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should be one after add, but it is not.")
	
	# Act
	object_under_test.clear_static_context()
	
	# Assert
	assert_eq(object_under_test.get_combined_message_data().size(), 1, "Size should still be one since messages
	should not be cleared with clear static context, but it is not.")	
	
