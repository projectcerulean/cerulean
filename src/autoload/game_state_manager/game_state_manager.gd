extends Node

@export var state: Resource

var transition: Node


func _ready() -> void:
	SignalsGetter.get_signals().request_game_pause.connect(self._on_request_game_pause)
	SignalsGetter.get_signals().request_game_quit.connect(self._on_request_game_quit)
	SignalsGetter.get_signals().request_game_unpause.connect(self._on_request_game_unpause)
	SignalsGetter.get_signals().request_scene_reload.connect(self._on_request_scene_reload)

	assert(state as StateResource != null, Errors.NULL_RESOURCE)


func _on_request_game_pause(_sender: Node) -> void:
	transition = state.states.PAUSE


func _on_request_game_quit(_sender: Node) -> void:
	get_tree().call_deferred(get_tree().quit.get_method())


func _on_request_game_unpause(_sender: Node) -> void:
	transition = state.states.GAMEPLAY


func _on_request_scene_reload(_sender: Node) -> void:
	transition = state.states.GAMEPLAY
	get_tree().call_deferred(get_tree().reload_current_scene.get_method())
