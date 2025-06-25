extends Node3D

# This will create a slot in the Inspector where you can drag your pick_up.tscn file.
@export var pick_up_scene: PackedScene

# How many pickups to create.
@export var number_of_pickups: int = 12

# The area around the center (0,0,0) where pickups will spawn.
@export var spawn_radius: float = 15.0

# _ready is called once when the node enters the scene tree for the first time.
func _ready():
	# Check if the pick_up_scene has been assigned in the Inspector.
	if not pick_up_scene:
		print("ERROR: Pick-up scene not set in the Level Manager.")
		return

	# Loop to create the specified number of pickups.
	for i in number_of_pickups:
		# Create a new instance of the PickUp scene.
		var pickup_instance = pick_up_scene.instantiate()

		# Generate a random position within the spawn radius.
		var spawn_position = Vector3(randf_range(-spawn_radius, spawn_radius), 1.0, randf_range(-spawn_radius, spawn_radius))
		
		# Set the position of the new pickup.
		pickup_instance.position = spawn_position
		
		# Add the new pickup to the main scene as a child of this node.
		add_child(pickup_instance)
