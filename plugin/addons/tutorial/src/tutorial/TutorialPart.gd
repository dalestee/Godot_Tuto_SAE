# File: res://addons/tuto/TutorialPart.gd
class_name TutorialPart
extends RefCounted

var title: String
var description: String
var steps: Array = []
var current_step_idx: int = 0

func _init(title_text: String = "", desc_text: String = ""):
	title = title_text
	description = desc_text
	steps = []

func get_step(index: int) -> TutorialStep:
	if index >= 0 and index < steps.size():
		return steps[index]
	return null
	
func get_current_step() -> TutorialStep:
	return get_step(current_step_idx)

func steps_count() -> int:
	return steps.size()

func next_step() -> TutorialStep:
	var step = get_step(current_step_idx)
	if not step: 
		return null
	current_step_idx += 1
	return step
