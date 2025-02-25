extends Node
class_name UpdateUtils



static func initialize():
	pass


static func init_xray_path(ret: bool = false):
	var xray_filename: String = ""
	
	if not DirAccess.dir_exists_absolute("user://xray"):
		print("Not found Xray core")
		return ""
	
	for filename in DirAccess.open("user://xray").get_files():
		if filename in ["xray", "xray.exe"]:
			if ret:
				print("Found xray %s" % "user://xray/" + filename)
				return "user://xray/" + filename
			else:
				print("Found xray %s" % "user://xray/" + filename)
				Globals.xray_path = "user://xray/" + filename
			break
	return ""


static func is_xray_installed():
	if init_xray_path(true):
		return true
	return false


static func create_temp_dictory():
	if not DirAccess.dir_exists_absolute("user://temp"):
		DirAccess.make_dir_absolute("user://temp")


static func get_local_xray_version():
	if not Globals.xray_path:
		return ""
	
	var re = RegEx.new()
	re.compile(r"Xray (?<version>\d+.\d+.\d+)")
	
	var version_output: Array = []
	OS.execute(ProjectSettings.globalize_path(Globals.xray_path), ["-version"], version_output, true, false)
	
	for row in version_output:
		var result = re.search(row)
		if result:
			return result.get_string("version")
	
	return ""


static func get_actual_xray_version():
	var re = RegEx.new()
	re.compile(r"Xray-core v(?<version>\d+.\d+.\d+)")
	Globals.http.request("https://github.com/XTLS/Xray-core/releases/latest")
	var data = await Globals.http.request_completed
	var result = re.search(data[3].get_string_from_utf8())
	if result:
		return result.get_string("version")
	return ""


static func get_xray_filename():
	var git_xray_filename: String = "Xray-"
	
	var osname: String = OS.get_name().to_lower()
	if not osname in ["linux", "windows", "android"]:
		return
	git_xray_filename += osname + "-"
	
	var arch: String = Engine.get_architecture_name()
	if arch in ["x86_64", "x86_32"]:
		arch = arch.substr(4)
	elif arch in ["arm64", "arm32"]:
		arch = arch + "-v8a"
	git_xray_filename += arch + ".zip"
	
	return git_xray_filename


static func check_xray_update(progress_bar: ProgressBar = null):
	if not DirAccess.dir_exists_absolute("user://xray"):
		DirAccess.make_dir_absolute("user://xray")
	
	var need_update: bool = false
	if Globals.xray_path:
		print("x")
		var xray_lv = get_local_xray_version()
		var xray_av = await get_actual_xray_version()
		if xray_av != xray_lv:
			need_update = true
	else:
		need_update = true
	
	if need_update:
		delete_xray()
		var git_xray_filename: String = get_xray_filename()
		var xray_download_url: String = "https://github.com/XTLS/Xray-core/releases/latest/download/" + git_xray_filename
		
		if progress_bar:
			Globals.downloader.stats_updated.connect(func(ds, dp, fn, fs) -> void: progress_bar.value = dp)
		Globals.downloader.start_download([xray_download_url], "user://temp")
		ZipUtils.unzip("user://temp/" + git_xray_filename, "user://xray")
		if OS.get_name().to_lower() == "linux":
			OS.execute("chmod", ["+x", ProjectSettings.globalize_path("user://xray/xray")])
		await Globals.downloader.downloads_finished


static func delete_xray():
	for f in DirAccess.get_files_at("user://xray"):
		DirAccess.remove_absolute("user://xray/" + f)


static func delete_temp():
	for f in DirAccess.get_files_at("user://temp"):
		DirAccess.remove_absolute("user://temp/" + f)
