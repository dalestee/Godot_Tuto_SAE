# scripts/fruit.gd
extends RigidBody2D

# This signal will be sent to the main game when the fruit is sliced.
signal sliced

# Export variables to easily set them in the Inspector for different fruits
@export var fruit_name = "apple"
@export var points = 10

# Preload the scene for the pieces that will spawn when sliced
var SlicedFruit = preload("res://scenes/sliced_fruit.tscn")

func _ready():
	# Set the texture based on the fruit_name
	$Sprite2D.texture = load("res://assets/%s.png" % fruit_name)

# This is the main function that handles slicing
func slice():
	# Emit the signal so the main game can award points
	emit_signal("sliced", points)

	# Create the two halves
	create_sliced_piece(-1) # Left half
	create_sliced_piece(1)  # Right half

	# Remove the original fruit
	queue_free()

func create_sliced_piece(direction: int):
	# Instance the SlicedFruit scene
	var piece = SlicedFruit.instantiate()

	# Add it to the same parent as the original fruit (the main game scene)
	get_parent().add_child(piece)

	# Set its texture to the correct half
	var piece_texture_path = "res://assets/%s_half_%d.png" % [fruit_name, 1 if direction == -1 else 2]
	piece.get_node("Sprite2D").texture = load(piece_texture_path)

	# Position the piece at the same place as the original fruit
	piece.global_position = global_position
	piece.rotation = rotation

	# Apply an impulse to make them fly apart
	var impulse_strength = 200
	var impulse_vector = Vector2(impulse_strength * direction, -impulse_strength / 2).rotated(rotation)
	piece.apply_central_impulse(impulse_vector)
