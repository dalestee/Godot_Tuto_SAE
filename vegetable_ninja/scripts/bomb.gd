# scripts/bomb.gd
extends RigidBody2D

signal exploded

# This function name is the same as the fruit's for simplicity.
# Our slicer doesn't need to know if it's a fruit or a bomb.
func slice():
	# Tell the main game we hit a bomb
	emit_signal("exploded")
	
	# Maybe add a particle effect for the explosion here
	
	queue_free()
