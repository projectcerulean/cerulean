extends Node


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"pause_menu"):
		get_tree().paused = not get_tree().paused

		$PauseMenu/ScreenBlur.visible = get_tree().paused
		$PauseMenu/ScreenDarken.visible = get_tree().paused
