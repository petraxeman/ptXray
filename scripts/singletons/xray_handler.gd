extends Node

var xray_pid
var current_config: Dictionary = {}

var logs: Dictionary = {}
var routing: Dictionary = {}
var dns: Dictionary = {}
var inbounds: Dictionary = {}
var outbounds: Dictionary = {}
var fakedns: Dictionary = {}



func _ready() -> void:
	_init_configs()
	_load_configs()
	_save_configs()


func start_xray():
	pass


func stop_xray():
	pass


func _init_configs():
	if not DirAccess.dir_exists_absolute("user://config"):
		DirAccess.make_dir_absolute("user://config")
	
	for filename in ["logs", "routing", "dns", "inbounds", "outbounds", "fakedns"]:
		if not FileAccess.file_exists("user://config/%s.json" % filename):
			_write_file("user://config/%s.json" % filename)


func _save_configs():
	for pair in [["logs", logs], ["routing", routing], ["dns", dns], ["inbounds", inbounds], ["outbounds", outbounds], ["fakedns", fakedns]]:
		_write_file("user://config/%s.json" % pair[0], pair[1])


func _load_configs():
	for pair in [["logs", logs], ["routing", routing], ["dns", dns], ["inbounds", inbounds], ["outbounds", outbounds], ["fakedns", fakedns]]:
		if FileAccess.file_exists("user://config/%s.json" % pair[0]):
			var file = FileAccess.open("user://config/%s.json" % pair[0], FileAccess.READ)
			pair[1].merge(JSON.parse_string(file.get_as_text()), true)


func _write_file(path: String, contents: Dictionary = {}):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(contents))
