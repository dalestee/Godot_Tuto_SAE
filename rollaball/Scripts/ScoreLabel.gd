extends Label

# _ready() is called when the node is ready.
func _ready():
	# When the game starts, immediately connect this label's update function
	# to the GameManager's score_updated signal.
	GameManager.score_updated.connect(update_text)
	
	# Also, set the initial text correctly.
	update_text(GameManager.current_score)

# This function will be called automatically whenever the GameManager emits the signal.
func update_text(new_score: int):
	# Update the label's text property.
	text = "Score: " + str(new_score)
