@tool
extends EditorPlugin

var tutorial_dock: Control
var popups: Array = []
var current_index := 0

func _enter_tree():
	tutorial_dock = preload("res://addons/tuto/dockTuto.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, tutorial_dock)
	var base_ui = get_editor_interface().get_base_control()

	var popup1 = PopUp.new("Click this button to add something.", base_ui.find_child("fefefe", true, false), _show_next_popup)
	base_ui.add_child(popup1)
	popups.append(popup1)

	var popup2 = PopUp.new("Next instruction here...", base_ui.find_child("Control", true, false), _show_next_popup)
	base_ui.add_child(popup2)
	popups.append(popup2)

	if popups.size() > 0:
		popups[0].show()

func _show_next_popup():
	current_index += 1
	if current_index < popups.size():
		if popups[current_index].target_node:
			popups[current_index].show()
		else: current_index += 1

func _exit_tree():
	for popup in popups:
		if is_instance_valid(popup):
			popup.queue_free()
	popups.clear()
	current_index = 0

	remove_control_from_docks(tutorial_dock)
	tutorial_dock.queue_free()
