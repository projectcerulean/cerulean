extends Area3D

@export var bgm: StringName


func _ready() -> void:
	assert(bgm == null or bgm == StringName() or bgm in BgmIndex.BGM_INDEX, Errors.INVALID_ARGUMENT)


func _on_body_entered(_body: Node3D) -> void:
	Signals.emit_bgm_area_entered(self, bgm)


func _on_body_exited(_body: Node3D) -> void:
	Signals.emit_bgm_area_exited(self)
