extends Control

var main_view: PackedScene = load("res://scenes/views/main_view.tscn")



func _ready() -> void:
	set_title("We are going")
	if not UpdateUtils.is_xray_installed():
		set_title("Not found xray")
		set_subtitle("Let's download it")
		set_subtitle("Founded %s version. Starting download." % await UpdateUtils.get_actual_xray_version())
		$vbox/progress.indeterminate = false
		await UpdateUtils.check_xray_update($vbox/progress)
		set_subtitle("")
	set_title("Done!")
	get_tree().create_timer(1).timeout.connect(redirect_back)

func redirect_back():
	var mw = main_view.instantiate()
	get_tree().root.add_child(mw)
	queue_free()

func set_title(text: String):
	$vbox/margin/label.text = text


func set_subtitle(text: String):
	$vbox/info.text = text
