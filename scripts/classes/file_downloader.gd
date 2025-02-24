class_name FileDownloader
extends HTTPRequest

signal downloads_started
signal file_downloaded
signal downloads_finished
signal stats_updated

@export var save_path: String = "user://cache/"
@export var file_urls: PackedStringArray

var _current_url       : String
var _current_url_index : int = 0

var _file : FileAccess
var _file_name : String
var _file_size : float

var _headers   : Array = []

var _downloaded_percent : float = 0
var _downloaded_size    : float = 0

var _last_method : int

var _busy : bool = false:
	get = is_busy,
	set = set_busy


func _init() -> void:
	use_threads = true
	set_process(false)
	connect("request_completed", Callable(self, "_on_request_completed"))


func _ready() -> void:
	set_process(false)


func _process(_delta) -> void:
	_update_stats()


func start_download(p_urls       : PackedStringArray = file_urls,
					p_save_path  : String = save_path) -> void:
	file_urls = p_urls
	save_path = p_save_path
	_create_directory()
	if not is_busy():
		_download_next_file()


func get_stats() -> Dictionary:
	var dictionnary : Dictionary
	dictionnary = {"downloaded_size"    : _downloaded_size,
				   "downloaded_percent" : _downloaded_percent,
				   "file_name"          : _file_name,
				   "file_size"          : _file_size}
	return dictionnary


func is_downloading() -> bool:
	# Depreciated. Will be removed in next release
	return is_busy()


func is_busy() -> bool:
	return _busy

func set_busy(p_busy : bool) -> void:
	_busy = p_busy


func _reset() -> void:
	_current_url = ""
	_current_url_index = 0
	_downloaded_percent = 0
	_downloaded_size = 0
	set_busy(false)


func _downloads_done() -> void:
	set_process(false)
	_update_stats()
	_reset()
	if _file:
		_file.close()
	emit_signal("downloads_finished")


func _send_head_request() -> void:
	# The HEAD method only gets the head and not the body. Therefore, doesn't
	#   download the file.
	request(_current_url, _headers, HTTPClient.METHOD_HEAD)
	_last_method = HTTPClient.METHOD_HEAD


func _send_get_request() -> void:
	var error = request(_current_url, _headers, HTTPClient.METHOD_GET)
	if error == OK:
		emit_signal("downloads_started")
		_last_method = HTTPClient.METHOD_GET
		set_process(true)

	elif error == ERR_INVALID_PARAMETER:
		push_error("Given string isn't a valid url: ", _current_url)
	elif error == ERR_CANT_CONNECT:
		push_error("Can't connect to host")


func _update_stats() -> void:
	_calculate_percentage()
	emit_signal("stats_updated",
				_downloaded_size,
				_downloaded_percent,
				_file_name,
				_file_size)


func _calculate_percentage() -> void:
	var error : int
	_file = FileAccess.open(save_path.path_join(_file_name), FileAccess.READ)
	error = FileAccess.get_open_error()

	if error == OK:
		_downloaded_size    = _file.get_length()
		_downloaded_percent = (_downloaded_size / _file_size) *100


func _create_directory() -> void:
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_recursive_absolute(save_path)


func _download_next_file() -> void:
	if _current_url_index < file_urls.size():
		set_busy(true)
		_current_url  = file_urls[_current_url_index]
		_file_name    = _current_url.get_file()
		download_file = save_path.path_join(_file_name)
		_send_head_request()
		_current_url_index += 1
	else:
		_downloads_done()


func _extract_regex_from_header(p_regex  : String,
								p_header : String) -> String:
	var regex = RegEx.new()
	regex.compile(p_regex)

	var result = regex.search(p_header)

	if result:
		return result.get_string()
	else:
		push_warning("File not found")
		return ""


func _on_request_completed(p_result,
						   _p_response_code,
						   p_headers,
						   _p_body) -> void:
	if p_result == RESULT_SUCCESS:
		if _last_method == HTTPClient.METHOD_HEAD:
			var regex = "(?i)content-length: [0-9]*"
			var size  = _extract_regex_from_header(regex, ' '.join(p_headers))
			size = size.replace("Content-Length: ", "")
			_file_size = size.to_float()
			_send_get_request()

		elif _last_method == HTTPClient.METHOD_GET:
			emit_signal("file_downloaded", _file_name)
			_download_next_file()
	else:
		push_error("HTTP Request error: ", p_result)


func _on_file_downloaded() -> void:
	_current_url_index += 1

	_update_stats()

	if _current_url_index < file_urls.size():
		_download_next_file()

	else:
		_downloads_done()
