@tool
extends EditorPlugin


var dock_instance: Control
var tutorial_dock: Control
var tutorial: Tutorial
var loader = preload("res://addons/tutorial/src/tutorial/TutorialLoader.gd").new()
var base_ui: Control
var popups: Array = []
var timer: Timer

func _enter_tree():
	dock_instance = preload("res://addons/tutorial/src/ui/DockScene.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock_instance)
	dock_instance.show()
	base_ui = get_editor_interface().get_base_control()
	timer = Timer.new()
	timer.wait_time = 0.05  # 50ms
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	_show_dock_infos()
	
func _on_timer_timeout():
	for popup in popups:
		if is_instance_valid(popup):
			popup.update_position()
	
func _show_next_popup():
	var step = tutorial.next_step()
	var part = tutorial.get_current_part()
	if not step or not part: return
	var node = base_ui.find_child(step.target_node, true, false)
	var popup = PopUp.new(step.description, node, _show_next_popup, part.current_step_idx, part.steps_count())
	popups.append(popup)
	base_ui.add_child(popup)
	_show_dock_infos()
	
func _dock_home():
	var tutorials = loader.list_all_tutorials()
	
	# Add layout
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock_instance.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = "Here are the available tutorials"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	title_label.add_theme_font_override("font", get_editor_interface().get_base_control().get_theme_font("bold", "Label"))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_label)
	
	for path in tutorials:
		# Open file and read first line as title
		var title = path.get_file().get_basename()
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			if not file.eof_reached():
				title = file.get_line()
			file.close()

		# Create and add the button
		var button = Button.new()
		button.text = title
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_tutorial_button_pressed.bind(path))
		vbox.add_child(button)

func _on_tutorial_button_pressed(file_path: String):
	tutorial = loader.load_tutorial(file_path)
	# Add layout
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dock_instance.add_child(vbox)
	
	_show_dock_infos()
	
func _dock_tutorial():
	# Container with padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	dock_instance.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(vbox)

	# Title row with back arrow
	var title_row = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_row)

	var back_button = Button.new()
	back_button.text = "←"
	back_button.tooltip_text = "Back"
	back_button.size_flags_horizontal = Control.SIZE_FILL
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.custom_minimum_size = Vector2(24, 24)
	back_button.pressed.connect(_on_back_button_pressed)
	title_row.add_child(back_button)

	var title_label = Label.new()
	title_label.text = tutorial.title
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	title_label.add_theme_font_override("font", get_editor_interface().get_base_control().get_theme_font("bold", "Label"))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_label)

	if !tutorial.started:
		# Description
		var desc_label = Label.new()
		desc_label.text = tutorial.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		vbox.add_child(desc_label)

		# Start button
		var start_button = Button.new()
		start_button.text = "Start Tutorial"
		start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start_button.pressed.connect(_on_start_button_pressed)
		vbox.add_child(start_button)
	else:
		var part = tutorial.get_current_part()
		if part:
			# Create an HBoxContainer to hold part title and part count side by side
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.add_child(hbox)

			# Part title label (left)
			var label_part_title = Label.new()
			label_part_title.text = part.title
			label_part_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label_part_title.add_theme_font_size_override("font_size", 18)
			label_part_title.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
			label_part_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label_part_title)

			# Part count label (right)
			var count_label = Label.new()
			count_label.text = str(tutorial.current_part_idx + 1) + " / " + str(tutorial.parts_count())
			count_label.add_theme_font_size_override("font_size", 12)
			count_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			count_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			hbox.add_child(count_label)

			# Part description (below)
			var label_part_desc = Label.new()
			label_part_desc.text = part.description
			label_part_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label_part_desc.add_theme_font_size_override("font_size", 13)
			label_part_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
			vbox.add_child(label_part_desc)

func _show_dock_infos():
	# Clear old content
	for child in dock_instance.get_children():
		dock_instance.remove_child(child)
		child.queue_free()
	
	if not tutorial: _dock_home()
	else: _dock_tutorial()
	
func _on_back_button_pressed():
	# Example: return to the start screen
	tutorial = null
	for popup in popups:
		if is_instance_valid(popup):
			popup.queue_free()
	popups.clear()
	_show_dock_infos()
	
func _on_start_button_pressed():
	_show_next_popup()

func _exit_tree():
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
		dock_instance = null
		
	for popup in popups:
		if is_instance_valid(popup):
			popup.queue_free()
	popups.clear()
	
	if tutorial_dock:
		remove_control_from_docks(tutorial_dock)
		tutorial_dock.queue_free()
		tutorial_dock = null
