# File: res://addons/tuto/TutorialLoader.gd
extends Node

const Tutorial := preload("res://addons/tutorial/src/tutorial/Tutorial.gd")
const TutorialPart := preload("res://addons/tutorial/src/tutorial/TutorialPart.gd")
const TutorialStep := preload("res://addons/tutorial/src/tutorial/TutorialStep.gd")

func load_tutorial(file_path: String) -> Tutorial:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open tutorial file: %s" % file_path)
		return null

	# Read the first two lines: title and description
	var title := ""
	var description := ""
	if not file.eof_reached():
		title = file.get_line().strip_edges()
	if not file.eof_reached():
		description = file.get_line().strip_edges()
	
	var tutorial := Tutorial.new(title, description)

	var current_part: TutorialPart = null

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue

		if line.begins_with('"'):
			var quote_end := line.find('",')
			if quote_end != -1 and current_part:
				var step_desc := line.substr(1, quote_end - 1).strip_edges()
				var step_target := line.substr(quote_end + 2).strip_edges()
				var step := TutorialStep.new(step_desc, step_target)
				current_part.steps.append(step)
		else:
			var fields := line.split(",", false)
			if fields.size() >= 2:
				current_part = TutorialPart.new(fields[0].strip_edges(), fields[1].strip_edges())
				tutorial.parts.append(current_part)

	file.close()
	return tutorial
