extends Node

# A signal that will be emitted whenever the score changes.
# The UI will listen for this signal to know when to update itself.
signal score_updated(new_score)

# The variable to hold the current score.
var current_score: int = 0

# A function to add points to the score.
func add_point():
	current_score += 1
	print("Score is now: ", current_score) # For debugging
	# Emit the signal to notify any listeners (like the UI) that the score has changed.
	score_updated.emit(current_score)

# A function to reset the score, e.g., when starting a new game.
func reset_score():
	current_score = 0
	score_updated.emit(current_score)
