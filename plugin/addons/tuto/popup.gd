extends Panel
class_name PopUp

var description_text: String
var target_node: Control
var on_next_callback: Callable

func _init(desc: String, target: Control, on_next: Callable) -> void:
	description_text = desc
	target_node = target
	on_next_callback = on_next

func _ready():
	set_position(calculate_position())
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	set("theme_override_styles/panel", get_stylebox())
	set_custom_minimum_size(Vector2(260, 100))

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	var label = Label.new()
	label.text = description_text
	vbox.add_child(label)

	# Wrap the button in an HBox to align right
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Add spacer first
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Create and add the "Next" button
	var button = Button.new()
	button.text = "Next"
	button.pressed.connect(_on_next_pressed)
	hbox.add_child(button)

	# Add the HBox to the VBox
	vbox.add_child(hbox)
	hide()

func calculate_position() -> Vector2:
	if target_node:
		var global_pos = target_node.get_global_rect().position
		return global_pos + Vector2(0, target_node.size.y + 10)
	return Vector2(100, 100)

func _on_next_pressed():
	hide()
	if on_next_callback:
		on_next_callback.call()

func get_stylebox() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.4, 0.4, 1)
	sb.set_corner_radius_all(8)
	return sb
