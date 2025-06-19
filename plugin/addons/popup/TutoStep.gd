# File: res://addons/tuto/TutorialStep.gd
class_name TutorialStep

extends RefCounted

var description: String
var target_node: String

func _init(desc: String = "", target: String = ""):
	description = desc
	target_node = target
