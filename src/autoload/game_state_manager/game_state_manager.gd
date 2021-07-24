extends Node

@export var state: Resource

var transition: Node


func _ready() -> void:
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().game_pause.get_name(), self._on_game_pause)
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().game_unpause.get_name(), self._on_game_unpause)

	assert(state as StateResource != null)


func _on_game_pause(_sender: Node) -> void:
	transition = state.states.PAUSE


func _on_game_unpause(_sender: Node) -> void:
	transition = state.states.GAMEPLAY
