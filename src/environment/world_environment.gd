extends WorldEnvironment


func _ready() -> void:
	Signals.camera_water_entered.connect(self._on_camera_water_entered)
	Signals.camera_water_exited.connect(self._on_camera_water_exited)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(environment != null, Errors.NULL_RESOURCE)


func _on_camera_water_entered(sender: Camera3D) -> void:
	if get_viewport().get_camera_3d() == sender:
		environment.fog_enabled = true


func _on_camera_water_exited(sender: Camera3D) -> void:
	if get_viewport().get_camera_3d() == sender:
		environment.fog_enabled = false


func _on_scene_changed(_sender: Node) -> void:
	environment.fog_enabled = false
