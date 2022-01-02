extends Area3D

@export var scene_key: StringName


func _ready() -> void:
	assert(scene_key != null, Errors.NULL_NODE)
	assert(scene_key in Levels.LEVELS, Errors.INVALID_ARGUMENT)


func _on_body_entered(body: Node3D) -> void:
	assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
	Signals.emit_request_scene_change(self, scene_key)
