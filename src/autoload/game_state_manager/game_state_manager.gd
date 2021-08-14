extends Node

@export var state: Resource

var transition: Node


func _ready() -> void:
	SignalsGetter.get_signals().request_game_pause.connect(self._on_request_game_pause)
	SignalsGetter.get_signals().request_game_unpause.connect(self._on_request_game_unpause)
	SignalsGetter.get_signals().request_dialogue_start.connect(self._on_request_dialogue_start)
	SignalsGetter.get_signals().request_dialogue_finish.connect(self._on_request_dialogue_finish)
	SignalsGetter.get_signals().request_scene_change.connect(self._on_request_scene_change)
	SignalsGetter.get_signals().request_scene_reload.connect(self._on_request_scene_reload)
	SignalsGetter.get_signals().request_game_quit.connect(self._on_request_game_quit)

	assert(state as StateResource != null, Errors.NULL_RESOURCE)


func _on_request_game_pause(_sender: Node) -> void:
	transition = state.states.PAUSE


func _on_request_game_unpause(_sender: Node) -> void:
	transition = state.states.GAMEPLAY


func _on_request_dialogue_start(_sender: Node3D, _dialogue_resource: DialogueResource) -> void:
	transition = state.states.DIALOGUE


func _on_request_dialogue_finish(_sender: Node) -> void:
	transition = state.states.GAMEPLAY


func _on_request_scene_change(_sender: Node, key: String) -> void:
	transition = state.states.GAMEPLAY
	get_tree().call_deferred(get_tree().change_scene.get_method(), Levels.LEVELS[key][Levels.LEVEL_PATH])


func _on_request_scene_reload(_sender: Node) -> void:
	transition = state.states.GAMEPLAY
	get_tree().call_deferred(get_tree().reload_current_scene.get_method())


func _on_request_game_quit(_sender: Node) -> void:
	get_tree().call_deferred(get_tree().quit.get_method())
