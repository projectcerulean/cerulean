extends Node

@export var state: Resource

var transition: Node


func _ready() -> void:
	SignalsGetter.get_signals().request_game_pause.connect(self._on_request_game_pause)
	SignalsGetter.get_signals().request_game_unpause.connect(self._on_request_game_unpause)

	assert(state as StateResource != null)


func _on_request_game_pause(_sender: Node) -> void:
	transition = state.states.PAUSE


func _on_request_game_unpause(_sender: Node) -> void:
	transition = state.states.GAMEPLAY
