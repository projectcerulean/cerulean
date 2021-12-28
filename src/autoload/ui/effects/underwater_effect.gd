extends ColorRect


func _ready():
	Signals.camera_water_entered.connect(self._on_camera_water_entered)
	Signals.camera_water_exited.connect(self._on_camera_water_exited)
	Signals.scene_changed.connect(self._on_scene_changed)


func _on_camera_water_entered(sender: Camera3D):
	if get_viewport().get_camera_3d() == sender:
		visible = true


func _on_camera_water_exited(sender: Camera3D):
	if get_viewport().get_camera_3d() == sender:
		visible = false


func _on_scene_changed(sender: Node):
	visible = false
