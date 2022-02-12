extends Node

@export var state_resource: Resource

var transition: StringName


func _ready() -> void:
	Signals.request_game_pause.connect(self._on_request_game_pause)
	Signals.request_game_unpause.connect(self._on_request_game_unpause)
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	Signals.request_dialogue_finish.connect(self._on_request_dialogue_finish)
	Signals.request_scene_transition_start.connect(self._on_request_scene_transition_start)
	Signals.request_scene_transition_finish.connect(self._on_request_scene_transition_finish)
	Signals.request_scene_change.connect(self._on_request_scene_change)
	Signals.request_game_quit.connect(self._on_request_game_quit)

	assert(state_resource as StateResource != null, Errors.NULL_RESOURCE)


func _on_request_game_pause(_sender: Node) -> void:
	transition = GameStates.PAUSE


func _on_request_game_unpause(_sender: Node) -> void:
	transition = GameStates.GAMEPLAY


func _on_request_dialogue_start(_sender: Node3D, _dialogue_resource: DialogueResource) -> void:
	transition = GameStates.DIALOGUE


func _on_request_dialogue_finish(_sender: Node) -> void:
	transition = GameStates.GAMEPLAY


func _on_request_scene_transition_start(_sender: Node, _scene: String, _color: Color, _fade_duration: float):
	transition = GameStates.SCENE_TRANSITION


func _on_request_scene_transition_finish(_sender: Node) -> void:
	transition = GameStates.GAMEPLAY


func _on_request_scene_change(_sender: Node, scene_path: String) -> void:
	get_tree().call_deferred(get_tree().change_scene.get_method(), scene_path)


func _on_request_game_quit(_sender: Node) -> void:
	get_tree().call_deferred(get_tree().quit.get_method())
