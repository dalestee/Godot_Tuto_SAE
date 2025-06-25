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

	var title := ""
	var description := ""
	if not file.eof_reached():
		title = file.get_line().strip_edges()
	if not file.eof_reached():
		description = file.get_line().strip_edges()

	var tutorial := Tutorial.new(title, description)

	var current_part: TutorialPart = null

	var pending_line = null

	while not file.eof_reached() or pending_line != null:
		var line := ""
		if pending_line != null:
			line = pending_line
			pending_line = null
		else:
			line = file.get_line().strip_edges()

		if line.is_empty():
			continue

		if line.begins_with('"'):
			# Step description line
			var quote_end := line.find('",')
			if quote_end != -1 and current_part:
				var step_desc := line.substr(1, quote_end - 1).strip_edges()
				var step_target := line.substr(quote_end + 2).strip_edges()

				# Peek next line to check for code block start
				if not file.eof_reached():
					var next_line := file.get_line()
					if next_line.strip_edges().begins_with("```"):
						# Read until closing ```
						var code_block := ""
						while not file.eof_reached():
							var code_line := file.get_line()
							if code_line.strip_edges() == "```":
								break
							code_block += code_line + "\n"
						var step := TutorialStep.new(step_desc, step_target, code_block.strip_edges())
						current_part.steps.append(step)
					else:
						# No code block, so store this line to process next iteration
						pending_line = next_line
						var step := TutorialStep.new(step_desc, step_target, "")
						current_part.steps.append(step)
		else:
			var fields := line.split(",", false)
			if fields.size() >= 2:
				current_part = TutorialPart.new(fields[0].strip_edges(), fields[1].strip_edges())
				tutorial.parts.append(current_part)

	file.close()
	return tutorial

func list_all_tutorials() -> Dictionary:
	var dir_path = "res://addons/tutorial/data"
	var result := {}

	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".txt"):
				var full_path = dir_path + "/" + file_name
				var file = FileAccess.open(full_path, FileAccess.READ)
				if file:
					var first_line = file.get_line()
					result[full_path] = first_line
					file.close()
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open directory: " + dir_path)

	return result
