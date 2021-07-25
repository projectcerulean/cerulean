extends Node


func _ready() -> void:
	Signals.emit_scene_changed(self)
