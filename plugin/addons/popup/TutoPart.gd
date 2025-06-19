# File: res://addons/tuto/TutorialPart.gd
class_name TutorialPart

extends RefCounted

var title: String
var description: String
var steps: Array = []

func _init(title_text: String = "", desc_text: String = ""):
	title = title_text
	description = desc_text
	steps = []
