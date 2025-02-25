extends Node

var http: HTTPRequest
var downloader: FileDownloader

var xray_path: String
var is_xray_installed: bool

var xray_pid


func _ready() -> void:
	if UpdateUtils.is_xray_installed():
		xray_path = UpdateUtils.init_xray_path(true)
		
	http = HTTPRequest.new()
	add_child(http)
	
	downloader = FileDownloader.new()
	add_child(downloader)
