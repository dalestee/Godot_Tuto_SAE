# scripts/main.gd
extends Node2D
@onready var score_label = $UI/ScoreLabel
# Preload the scenes we'll be instancing
var FruitScene = preload("res://scenes/fruit.tscn")
var BombScene = preload("res://scenes/bomb.tscn") # We will create this next

var score = 0
var is_swiping = false
var swipe_points = []

@onready var spawn_timer = $SpawnTimer
@onready var swipe_trail = $Line2D

func _ready():
	# Connect the timer's timeout signal to our spawning function
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# We need a UI Label to show the score, we will create it in Step 5
	# For now, we'll just print to the console.
	update_score(0)

func _process(delta):
	# Update the swipe trail visualization
	if is_swiping:
		swipe_trail.add_point(get_global_mouse_position())
	else:
		# Clear the trail if not swiping
		if swipe_trail.get_point_count() > 0:
			swipe_trail.clear_points()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_swiping = event.pressed
			if not is_swiping:
				# Clear the swipe points when mouse is released
				swipe_points.clear()

	if event is InputEventMouseMotion and is_swiping:
		var current_pos = event.position
		# Store the current point for collision detection
		swipe_points.append(current_pos)
		# Keep the array from getting too big
		if swipe_points.size() > 20:
			swipe_points.pop_front()
		
		detect_slice()

func detect_slice():
	if swipe_points.size() < 2:
		return

	var start_point = swipe_points[0]
	var end_point = swipe_points[-1]

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start_point, end_point)
	
	# --- THIS IS THE CRITICAL FIX ---
	# We tell the query to ONLY look for Areas and ignore Bodies.
	query.collide_with_areas = true
	query.collide_with_bodies = false
	# ------------------------------

	var result = space_state.intersect_ray(query)

	if result:
		# 'result.collider' is now guaranteed to be the Area2D we hit.
		# We check if this Area2D is in our "fruits" group.
		if result.collider.is_in_group("fruits"):
			# The Area2D's parent is the RigidBody (Fruit or Bomb) which has the slice() function.
			result.collider.get_parent().slice()
			
# In main.gd, update the spawner function
func _on_spawn_timer_timeout():
	var screen_size = get_viewport_rect().size
	var spawn_pos = Vector2(randf_range(0, screen_size.x), screen_size.y + 100)

	# Decide whether to spawn a fruit or a bomb
	var instance
	if randf() > 0.2: # 80% chance for a fruit
		instance = FruitScene.instantiate()
		instance.sliced.connect(_on_fruit_sliced)
	else: # 20% chance for a bomb
		instance = BombScene.instantiate()
		instance.exploded.connect(game_over) # Connect to our game_over function

	instance.position = spawn_pos
	add_child(instance)

	var impulse_x = randf_range(-150, 150)
	var impulse_y = randf_range(-800, -1000)
	instance.apply_central_impulse(Vector2(impulse_x, impulse_y))
	instance.apply_torque_impulse(randf_range(-200, 200))


func _on_fruit_sliced(points):
	update_score(points)

func update_score(points_to_add):
	score += points_to_add
	score_label.text = "Score: " + str(score)
	
func game_over():
	print("GAME OVER! Final Score: ", score)
	get_tree().paused = true # Pause the entire game
	# Add a game over label to the UI scene and show it here
	# e.g. $UI/GameOverLabel.text = "Game Over!\nFinal Score: " + str(score)
	# $UI/GameOverLabel.show()
