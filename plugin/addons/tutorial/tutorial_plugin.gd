@tool
extends EditorPlugin

var dock_instance: Control
var tutorial_dock: Control
var tutorial: Tutorial
var base_ui: Control
var popups: Array = []

func _enter_tree():
	dock_instance = preload("res://addons/tutorial/src/ui/DockScene.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock_instance)
	dock_instance.show()
	base_ui = get_editor_interface().get_base_control()
	var loader = preload("res://addons/tutorial/src/tutorial/TutorialLoader.gd").new()
	tutorial = loader.load_tutorial("res://addons/tutorial/data/tutorial_vegetable.txt")
	_show_next_popup()

func _show_next_popup():
	var step = tutorial.next_step()
	if not step: return
	var node = base_ui.find_child(step.target_node, true, false)
	var popup = PopUp.new(step.description, node, _show_next_popup)
	popups.append(popup)
	base_ui.add_child(popup)
	_show_dock_infos()
	
func _show_dock_infos():
	for child in dock_instance.get_children():
		dock_instance.remove_child(child)
		child.queue_free()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dock_instance.add_child(vbox)

	var label1 = Label.new()
	label1.text = tutorial.title
	vbox.add_child(label1)

	var label2 = Label.new()
	label2.text = tutorial.description
	vbox.add_child(label2)

func _exit_tree():
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.queue_free()
		dock_instance = null
		
	for popup in popups:
		if is_instance_valid(popup):
			popup.queue_free()
	popups.clear()

	remove_control_from_docks(tutorial_dock)
	tutorial_dock.queue_free()
