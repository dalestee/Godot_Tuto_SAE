extends RigidBody3D

@export var speed := 10.0

func _physics_process(delta):
	var input_vector = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		input_vector.z -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.z += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	input_vector = input_vector.normalized()
	if input_vector != Vector3.ZERO:
		apply_central_force(input_vector * speed)
