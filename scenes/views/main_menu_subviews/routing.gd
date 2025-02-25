extends MarginContainer

var domain_strategies = {
	0: "AsIs",
	1: "IPIfNonMatch",
	2: "IPOnDemand"
}

var domain_matchers = {
	0: "hybrid",
	1: "linear"
}



func _ready() -> void:
	render()


func render():
	for child in $scroll/vbox/rules.get_children():
		child.queue_free()
	
	var lbl = Label.new()
	lbl.text = "Rules"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("Arial", 18)
	$scroll/vbox/rules.add_child(lbl)
	
	# --- Code for creating a rules
	
	
	var btn = Button.new()
	btn.text = "+"
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_open_create_new_rule)
	$scroll/vbox/rules.add_child(btn)
	
	for i in domain_strategies:
		if domain_strategies[i] == XrayHandler.routing.get("domainStrategy", "AsIs"):
			$scroll/vbox/domain_strategy/option.selected = i
			break
	for i in domain_matchers:
		if domain_matchers[i] == XrayHandler.routing.get("domainMatcher", "hybrid"):
			$scroll/vbox/domain_matcher/option.selected = i
			break


func _on_domain_strategy_selected(index: int) -> void:
	XrayHandler.routing["domainStrategy"] = $scroll/vbox/domain_strategy/option.get_item_text(index)
	XrayHandler._save_configs()
	render()


func _on_domain_matcher_selected(index: int) -> void:
	XrayHandler.routing["domainMatcher"] = $scroll/vbox/domain_matcher/option.get_item_text(index)
	XrayHandler._save_configs()
	render()


func _open_create_new_rule():
	$create_new_rule.exclusive = true
	$create_new_rule.show()


func _on_accept_route_rule_creation():
	var route_rule = {
		"type": "field",
		"enabled": $create_new_rule/scroll/margin/vbox/enable/check.button_pressed,
		"domainMatcher": _get_current_item($create_new_rule/scroll/margin/vbox/matcher/option),
		"domain": _split_by($create_new_rule/scroll/margin/vbox/domain/edit),
		"ip": _split_by($create_new_rule/scroll/margin/vbox/ip/edit),
		"network": _get_current_item($create_new_rule/scroll/margin/vbox/network/option),
		"source": _split_by($create_new_rule/scroll/margin/vbox/source/edit),
		"inboundTag": _get_current_item($create_new_rule/scroll/margin/vbox/inbound_tag/option),
		"protocol": _get_current_item($create_new_rule/scroll/margin/vbox/protocol/option)
	}
	
	if $create_new_rule/scroll/margin/vbox/port/edit.text:
		route_rule["port"] = $create_new_rule/scroll/margin/vbox/port/edit.text
	if $create_new_rule/scroll/margin/vbox/source_port/edit.text:
		route_rule["sourcePort"] = $create_new_rule/scroll/margin/vbox/source_port/edit.text
	
	print(route_rule)


func _split_by(edit: TextEdit, delimiter: String = ","):
	var raw_elements = edit.text.split(delimiter)
	var prepared_elements = []
	for re in raw_elements:
		var el = re.strip_edges().strip_escapes()
		if el:
			prepared_elements.append(el)
	return prepared_elements


func _get_current_item(opt: OptionButton):
	return opt.get_item_text(opt.selected)


func _on_cancel_route_rule_creation():
	$create_new_rule.hide()
