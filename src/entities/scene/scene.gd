extends Node

@export var bgm_resource: Resource


func _ready() -> void:
	if bgm_resource != null:
		assert(bgm_resource as BgmResource != null, Errors.NULL_RESOURCE)
	Signals.emit_scene_changed(self)
