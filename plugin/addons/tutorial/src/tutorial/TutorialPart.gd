# File: res://addons/tuto/TutorialPart.gd
class_name TutorialPart
extends RefCounted

const TutorialStep := preload("res://addons/tutorial/src/tutorial/TutorialStep.gd")

var title: String
var description: String
var steps: Array = []
var current_step_idx: int = -1

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
	current_step_idx += 1
	var step = get_step(current_step_idx)
	if not step: 
		return null
	return step

func previous_step() -> TutorialStep:
	current_step_idx -= 1
	if current_step_idx < 0:
		current_step_idx = -1
	return get_step(current_step_idx)
