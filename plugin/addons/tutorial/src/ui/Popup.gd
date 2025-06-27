# --- RECOMMENDED VERSION ---
# We extend PanelContainer, which is designed to hold a child and resize to fit it.
extends PanelContainer
class_name PopUp

# --- Input Properties ---
var description_text: String
var target_node: Control
var on_next_callback: Callable
var on_previous_callback: Callable
var current_step: int = 1
var total_steps: int = 1


# --- Configuration ---
# This still defines the maximum width before the text starts wrapping.
@export var max_width: float = 300.0

func _init(desc: String, target: Control, on_next: Callable, on_previous: Callable, step: int = 1, total: int = 1) -> void:
	description_text = desc
	target_node = target
	on_next_callback = on_next
	on_previous_callback = on_previous
	current_step = step
	total_steps = total
	
func _ready():
	# --- Sizing and Positioning ---
	# Set the maximum width. The PanelContainer's height will be determined by its content.
	size.x = max_width
	
	set_position(calculate_position())
	set_anchors_preset(Control.PRESET_TOP_LEFT)

	# --- Style and Padding ---
	# PanelContainer has built-in styling and padding, so we apply overrides directly to it.
	# This is the modern, cleaner way to set theme properties.
	add_theme_stylebox_override("panel", get_stylebox())

	# --- Child Node Setup ---
	# We no longer need a separate MarginContainer. We add the VBox directly to the PanelContainer.
	var vbox = VBoxContainer.new()
	add_child(vbox)

	var label = Label.new()
	label.text = description_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Step counter
	var step_label = Label.new()
	step_label.text = "Step %d / %d" % [current_step, total_steps]
	step_label.add_theme_font_size_override("font_size", 12)
	step_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	vbox.add_child(step_label)
	
	# **THIS IS THE KEY FIX**
	# Tell the label to fill the horizontal space given to it by its parent.
	# Without this, it stays at its minimum size, causing the layout to collapse.
	label.size_flags_horizontal = Control.SIZE_FILL

	vbox.add_child(label)

	# The button layout remains the same.
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(hbox)

	var button2 = Button.new()
	button2.text = "Previous"
	button2.pressed.connect(_on_previous_pressed)
	hbox.add_child(button2)
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var button = Button.new()
	button.text = "Next"
	button.pressed.connect(_on_next_pressed)
	hbox.add_child(button)



func calculate_position() -> Vector2:
	if not is_instance_valid(target_node):
		return Vector2(100, 100)

	var target_rect = target_node.get_global_rect()
	var popup_size = size
	var screen_size = get_viewport_rect().size

	var positions = [
		target_rect.position + Vector2(target_rect.size.x + 10, 0),  # Right
		target_rect.position - Vector2(popup_size.x + 10, 0),        # Left
		target_rect.position + Vector2(0, target_rect.size.y + 10),  # Bottom
		target_rect.position - Vector2(0, popup_size.y + 10)         # Top
	]

	for pos in positions:
		var bottom_right = pos + popup_size
		if pos.x >= 0 and pos.y >= 0 and bottom_right.x <= screen_size.x and bottom_right.y <= screen_size.y:
			return pos

	# Fallback: Clamp to stay on screen
	return Vector2(
		clamp(target_rect.position.x, 0, screen_size.x - popup_size.x),
		clamp(target_rect.position.y, 0, screen_size.y - popup_size.y)
	)
	
func update_position():
	position = calculate_position()
	
func _on_next_pressed():
	hide()
	if on_next_callback.is_valid():
		on_next_callback.call()

func _on_previous_pressed():
	hide()
	if on_previous_callback.is_valid():
		on_previous_callback.call()

func get_stylebox() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.4, 0.4, 1)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(10)  # Or set_content_margin_* individually if needed
	return sb
