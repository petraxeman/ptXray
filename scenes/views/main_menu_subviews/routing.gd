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
	$create_new_rule.show()
	$scroll/vbox/domain_strategy/option.disabled = true
	$scroll/vbox/domain_matcher/option.disabled = true
