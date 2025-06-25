# File: res://addons/tuto/TutorialStep.gd
class_name TutorialStep

extends RefCounted

var description: String
var target_node: String
var code: String

func _init(desc: String = "", target: String = "", _code: String = ""):
	description = desc
	target_node = target
	code = _code
