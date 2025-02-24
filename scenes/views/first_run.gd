extends Control



func _ready() -> void:
	first_messages()


func first_messages():
	delayed_message(r"Oh, hello! We wanna try ptXray?", 0.5)
	delayed_message(r"Ok, i feel you. Let's go.", 1)
	delayed_message(r"First, let me see if you have Xray installed...", 1.5)
	get_tree().create_timer(1.5).timeout.connect(check_xray)


func check_xray():
	var need_update: bool = false
	
	if not UpdateUtils.is_xray_installed():
		add_label_to_log("Oh, you don't have any xray. Let me download it.")
		need_update = true
	elif UpdateUtils.get_local_xray_version() != await UpdateUtils.get_actual_xray_version():
		print(UpdateUtils.get_local_xray_version(), " | ", await UpdateUtils.get_actual_xray_version())
		add_label_to_log("Your xray is old... Let me download new version.")
		need_update = true
	else:
		add_label_to_log("Fine. You already have actual xray version.")
	
	
	if need_update:
		get_tree().create_timer(1).timeout.connect(
			update_xray
		)
	else:
		add_label_to_log("Wow, your nice. Why program redirect you here... Stupid programs.")


func update_xray():
	add_label_to_log("Ok, fine. Now i download and install xray: " + UpdateUtils.get_xray_filename())
	var x = await UpdateUtils.check_xray_update($vbox/progress)
	add_label_to_log("Ok. All right. Bye bye.")

func delayed_message(text, delay):
	get_tree().create_timer(delay).timeout.connect(
		func(): add_label_to_log(text)
		)


func add_label_to_log(text: String):
	var lbl = Label.new()
	lbl.text = "- " + text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$vbox/margin2/scroll/vbox.add_child(lbl)
	$vbox/margin2/scroll/vbox.move_child(lbl, 0)
	
