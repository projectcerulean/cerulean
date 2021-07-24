extends Node


@export var game_state: Resource


func _ready():
	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pause"):
		if game_state.state == game_state.states.GAMEPLAY:
			SignalsGetter.get_signals().emit_request_game_pause(self)
		elif game_state.state == game_state.states.PAUSE:
			SignalsGetter.get_signals().emit_request_game_unpause(self)
