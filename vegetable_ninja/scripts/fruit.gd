# scripts/fruit.gd (UPDATED)
extends RigidBody2D

# We now have TWO signals this fruit can send
signal sliced
signal fruit_missed

@export var fruit_name = "apple"
@export var points = 10

var SlicedFruit = preload("res://scenes/sliced_fruit.tscn")

@onready var notifier = $VisibleOnScreenNotifier2D

func _ready():
	# Set the texture based on the fruit_name
	$Sprite2D.texture = load("res://assets/%s.png" % fruit_name)
	# Connect the notifier's signal to a function IN THIS SCRIPT
	notifier.screen_exited.connect(_on_screen_exited)

func slice():
	# Prevent a fruit from being both "missed" and "sliced" at the same time
	notifier.screen_exited.disconnect(_on_screen_exited)
	emit_signal("sliced", points)
	create_sliced_piece(-1)
	create_sliced_piece(1)
	queue_free()

func create_sliced_piece(direction: int):
	var piece = SlicedFruit.instantiate()
	get_parent().add_child(piece)
	var piece_texture_path = "res://assets/%s_half_%d.png" % [fruit_name, 1 if direction == -1 else 2]
	piece.get_node("Sprite2D").texture = load(piece_texture_path)
	piece.global_position = global_position
	piece.rotation = rotation
	var impulse_strength = 200
	var impulse_vector = Vector2(impulse_strength * direction, -impulse_strength / 2).rotated(rotation)
	piece.apply_central_impulse(impulse_vector)

# This function is called when the fruit leaves the screen
func _on_screen_exited():
	emit_signal("fruit_missed")
	queue_free() # Clean up the missed fruit
