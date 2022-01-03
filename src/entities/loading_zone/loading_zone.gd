extends Area3D

@export var scene_key: StringName
@export var scene_transition_color: Color = Color(0.02, 0.02, 0.02)
@export var fade_duration: float = 1.5


func _ready() -> void:
	assert(scene_key != null, Errors.NULL_NODE)
	assert(scene_key in Levels.LEVELS, Errors.INVALID_ARGUMENT)


func _on_body_entered(body: Node3D) -> void:
	assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
	var scene_path: String = Levels.LEVELS[scene_key][Levels.LEVEL_PATH]
	Signals.emit_request_scene_transition_start(self, scene_path, scene_transition_color, fade_duration)
