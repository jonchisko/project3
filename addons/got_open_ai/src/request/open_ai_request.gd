extends OpenAiRequestBase

class_name OpenAiRequest


func request_data(url: String, headers: PackedStringArray, method: HTTPClient.Method, request_data: Dictionary) -> String:
	var error: Error = 0
	var http: HTTPClient = HTTPClient.new() # TODO: should be perhaps constructed just once in constructor.
	
	var url_data = url.split(".com")
	var url_base: String = "{url}.com".format({"url" : url_data[0]})
	var end_point: String = url_data[1]

	error = http.connect_to_host(url_base, 443)
	if error != Error.OK:
		printerr("Connecting to host failed.")
		return ""
	
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		await get_tree().process_frame
	
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		printerr("HTTPClient is not connected.")
		return ""
	
	error = http.request(method, end_point, headers, JSON.stringify(request_data))
	if error != Error.OK:
		printerr("Something went wrong with the request.")
		return ""
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		await get_tree().process_frame

	if http.get_status() != HTTPClient.STATUS_BODY and http.get_status() != HTTPClient.STATUS_CONNECTED:
		printerr("HTTP request did not finish well.")
		return ""

	if not http.has_response():
		return ""
	
	var returned_bytes = PackedByteArray()
	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk = http.read_response_body_chunk()
		if chunk.size() == 0:
			await get_tree().process_frame
		else:
			returned_bytes = returned_bytes + chunk
	var json_data = returned_bytes.get_string_from_ascii()
	
	return json_data
