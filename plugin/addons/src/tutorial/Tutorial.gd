# File: res://addons/tuto/Tutorial.gd
class_name Tutorial
extends RefCounted

const TutorialPart := preload("res://addons/src/tutorial/TutorialPart.gd")

var title: String = ""
var description: String = ""
var parts: Array[TutorialPart] = []
var current_part_idx: int = 0

func _init(tutorial_title: String = "", tutorial_description: String = ""):
	title = tutorial_title
	description = tutorial_description
	parts = []

func get_part(index: int) -> TutorialPart:
	if index >= 0 and index < parts.size():
		return parts[index]
	return null

func parts_count() -> int:
	return parts.size()

func get_current_step() -> TutorialStep:
	var part = get_part(current_part_idx)
	if not part:
		return null
	return part.get_current_step()

# Advance to next step, returns:
# - true if moved to next step or part
# - false if tutorial finished
func next_step() -> TutorialStep:
	var part = get_part(current_part_idx)
	if not part:
		return null
		
	var next_part_step = part.next_step()
	if not next_part_step:
		current_part_idx += 1
		return next_step()
	
	return next_part_step
