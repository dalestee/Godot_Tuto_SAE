extends Area3D

# The speed at which the object will rotate, in radians per second.
# You can change this value in the Inspector.
@export var rotation_speed: float = 2.0

# _process is called every frame. 'delta' is the time since the last frame.
func _process(delta):
	# Rotate the object around its own Y (upward) axis.
	# Multiplying by delta makes the rotation smooth and frame-rate independent.
	rotate_y(rotation_speed * delta)

	# Check if the colliding body is the player.
func _on_body_entered(body: Node3D):
	# Check if the colliding body is the player.
	if body.is_in_group("player"):
		
		GameManager.add_point()
		# -------------------
		
		# The pickup still disappears as before.
		queue_free()
