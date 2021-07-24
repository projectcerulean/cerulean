extends ColorRect


func _ready():
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().camera_water_entered.get_name(), self._on_camera_water_entered)
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().camera_water_exited.get_name(), self._on_camera_water_exited)


func _on_camera_water_entered(sender: Camera3D):
	if get_viewport().get_camera() == sender:
		visible = true


func _on_camera_water_exited(sender: Camera3D):
	if get_viewport().get_camera() == sender:
		visible = false
