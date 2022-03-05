extends GameState


func enter(data: Dictionary) -> void:
	super.enter(data)
	get_tree().paused = true


func exit(data: Dictionary) -> void:
	super.exit(data)
	get_tree().paused = false
