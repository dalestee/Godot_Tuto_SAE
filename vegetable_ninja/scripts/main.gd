# scripts/main.gd (FINAL VERSION)
extends Node2D

var FruitScene = preload("res://scenes/fruit.tscn")
var GameOverScreen = preload("res://scenes/game_over_screen.tscn")

var score = 0
var missed_fruits = 0
const MAX_MISSES = 3

var is_swiping = false
var swipe_points = []

@onready var spawn_timer = $SpawnTimer
@onready var swipe_trail = $Line2D
@onready var score_label = $UI/ScoreLabel
@onready var misses_label = $UI/MissesLabel # <-- Reference to new label

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	update_score(0)
	update_misses() # Initialize the misses display

func _process(delta):
	if is_swiping:
		swipe_trail.add_point(get_global_mouse_position())
	else:
		if swipe_trail.get_point_count() > 0:
			swipe_trail.clear_points()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_swiping = event.pressed
		if not is_swiping:
			swipe_points.clear()

	if event is InputEventMouseMotion and is_swiping:
		swipe_points.append(event.position)
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
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result = space_state.intersect_ray(query)

	if result and result.collider.is_in_group("fruits"):
		result.collider.get_parent().slice()

# This is our updated spawner function from Step 1
func _on_spawn_timer_timeout():
	var screen_size = get_viewport_rect().size
	var spawn_pos = Vector2(randf_range(0, screen_size.x), screen_size.y + 100)

	var fruit = FruitScene.instantiate()
	
	fruit.sliced.connect(_on_fruit_sliced)
	fruit.fruit_missed.connect(_on_fruit_missed) # This now works!

	fruit.position = spawn_pos
	add_child(fruit)

	var impulse_x = randf_range(-150, 150)
	var impulse_y = randf_range(-800, -1000)
	fruit.apply_central_impulse(Vector2(impulse_x, impulse_y))
	fruit.apply_torque_impulse(randf_range(-200, 200))

func _on_fruit_sliced(points):
	update_score(points)

# --- NEW FUNCTION TO HANDLE A MISSED FRUIT ---
func _on_fruit_missed():
	missed_fruits += 1
	update_misses()
	if missed_fruits >= MAX_MISSES:
		game_over()

func update_score(points_to_add):
	score += points_to_add
	score_label.text = "Score: " + str(score)

# --- NEW FUNCTION TO UPDATE THE UI ---
func update_misses():
	misses_label.text = "Misses: %d / %d" % [missed_fruits, MAX_MISSES]

func game_over():
	# Pause the game so fruits stop moving in the background
	get_tree().paused = true
	
	# Create an instance of our game over screen
	var game_over_instance = GameOverScreen.instantiate()
	
	# Add it to the scene tree so it becomes visible
	add_child(game_over_instance)
	
	# Call the function on the game over screen to pass it the final score
	game_over_instance.show_final_score(score)
