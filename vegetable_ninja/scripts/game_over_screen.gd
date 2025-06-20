# scripts/game_over_screen.gd
extends CanvasLayer

# A reference to the label so we can set the score from main.gd
@onready var final_score_label = $FinalScoreLabel

# This function is called when the RestartButton is clicked
func _on_restart_button_pressed():
	# Unpause the game so the new scene can run correctly
	get_tree().paused = false
	
	# Reload the entire main game scene to start over
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# A helper function we will call from the main game to show the score
func show_final_score(score: int):
	final_score_label.text = "Final Score: " + str(score)
