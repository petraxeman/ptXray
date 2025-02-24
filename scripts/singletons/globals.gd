extends Node

var http: HTTPRequest
var downloader: FileDownloader

var xray_path: String
var is_xray_installed: bool



func _ready() -> void:
	if UpdateUtils.is_xray_installed():
		var new_xray_path = UpdateUtils.init_xray_path(true)
		xray_path = new_xray_path
		
	http = HTTPRequest.new()
	add_child(http)
	
	downloader = FileDownloader.new()
	add_child(downloader)
