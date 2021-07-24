extends ColorRect


func _ready():
	SignalsGetter.get_signals().camera_water_entered.connect(self._on_camera_water_entered)
	SignalsGetter.get_signals().camera_water_exited.connect(self._on_camera_water_exited)


func _on_camera_water_entered(sender: Camera3D):
	if get_viewport().get_camera_3d() == sender:
		visible = true


func _on_camera_water_exited(sender: Camera3D):
	if get_viewport().get_camera_3d() == sender:
		visible = false
