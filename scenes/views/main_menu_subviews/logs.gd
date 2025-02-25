extends MarginContainer

var loglevels = {
	0: "debug",
	1: "info",
	2: "warning",
	3: "error",
	4: "none"
}

var mask_address = {
	0: "quarter",
	1: "half",
	2: "full",
	3: "none"
}



func _ready():
	render()


func render():
	$vbox/access/access_choice.text = XrayHandler.logs.get("access", "Choice directory")
	$vbox/error/error_choice.text = XrayHandler.logs.get("error", "Choice directory")
	for i in loglevels:
		if loglevels[i] == XrayHandler.logs.get("loglevel", "none"):
			$vbox/loglevel/options.selected = i
			break
	for i in mask_address:
		if mask_address[i] == XrayHandler.logs.get("maskAddress", "none"):
			$vbox/mask_address/options.selected = i
			break
	$vbox/dnslog/check.button_pressed = XrayHandler.logs.get("dnsLog", false)


func _on_access_choice_pressed() -> void:
	$vbox/access/FileDialog.show()


func _on_file_dialog_file_selected(path: String) -> void:
	XrayHandler.logs["access"] = ProjectSettings.globalize_path(path)
	XrayHandler._save_configs()
	render()


func _on_error_choice_pressed() -> void:
	$vbox/error/error_file_selector.show()


func _on_error_file_selector_file_selected(path: String) -> void:
	XrayHandler.logs["error"] = ProjectSettings.globalize_path(path)
	XrayHandler._save_configs()
	render()


func _on_loglevel_selected(index: int) -> void:
	XrayHandler.logs["loglevel"] = $vbox/loglevel/options.get_item_text(index)
	XrayHandler._save_configs()
	render()


func _on_dnslog_changed() -> void:
	XrayHandler.logs["dnsLog"] = $vbox/dnslog/check.button_pressed
	XrayHandler._save_configs()
	render()


func _on_mask_adress_option_selected(index: int) -> void:
	if index == 4:
		XrayHandler.logs.erase("maskAddress")
	else:
		XrayHandler.logs["maskAddress"] = $vbox/mask_address/options.get_item_text()
	XrayHandler._save_configs()
	render()
