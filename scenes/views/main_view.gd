extends Control

var activate_view: PackedScene = load("res://scenes/views/main_menu_subviews/activate.tscn")
var logs_view: PackedScene = load("res://scenes/views/main_menu_subviews/logs.tscn")



func _ready() -> void:
	print(UpdateUtils.get_local_xray_version())


func _on_open_menu_pressed() -> void:
	$slide_menu.play("slide_out")


func _on_close_pressed() -> void:
	$slide_menu.play("slide_in")


func _clear_active_page():
	for view in $active_page.get_children():
		view.queue_free()


func _on_show_activate_view_pressed() -> void:
	_clear_active_page()
	var prepared_view = activate_view.instantiate()
	$active_page.add_child(prepared_view)
	_on_close_pressed()


func _on_show_logs_view_pressed() -> void:
	_clear_active_page()
	var prepared_view = logs_view.instantiate()
	$active_page.add_child(prepared_view)
	_on_close_pressed()
