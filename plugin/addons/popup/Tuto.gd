extends Node

func load_tutorial_parts(path: String) -> Array[TutorialPart]:
	var parts: Array[TutorialPart] = []
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not open file: %s" % path)
		return parts

	var current_part: TutorialPart = null

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty():
			continue

		# Check for step line: "Description", TargetNode
		if line.begins_with('"'):
			var matches := line.match('"([^"]+)",\s*(.+)')
			if matches:
				var step = TutorialStep.new(matches[1], matches[2])
				if current_part:
					current_part.steps.append(step)
		else:
			# New part line: Part Title, Part Description
			var fields = line.split(",", false)
			if fields.size() >= 2:
				current_part = TutorialPart.new()
				current_part.title = fields[0].strip_edges()
				current_part.description = fields[1].strip_edges()
				current_part.steps = []
				parts.append(current_part)

	file.close()
	return parts


var tutorial_parts = load_tutorial_parts("res://addons/data/tuto.txt")

for part in tutorial_parts:
	print("PART:", part.title, "-", part.description)
	for step in part.steps:
		print("   STEP:", step.description, "->", step.target_node)
