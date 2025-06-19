extends Camera3D

@export var target: Node3D

var offset: Vector3

func _ready():
	if target:
		offset = global_transform.origin - target.global_transform.origin

func _process(delta):
	if target:
		global_transform.origin = target.global_transform.origin + offset
