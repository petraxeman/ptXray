extends VBoxContainer



func _ready() -> void:
	if Globals.xray_pid:
		$status.text = "Status: enabled"
	else:
		$status.text = "Status: disabled"
