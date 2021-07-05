extends ColorRect


func _ready():
	Signals.connect(Signals.area_area_entered.get_name(), self._on_area_area_entered)
	Signals.connect(Signals.area_area_exited.get_name(), self._on_area_area_exited)


func _on_area_area_entered(sender: Area3D, area: Area3D):
	if sender.owner.name == "Water" and area.owner.name == "Camera3D":
		visible = true


func _on_area_area_exited(sender: Area3D, area: Area3D):
	if sender.owner.name == "Water" and area.owner.name == "Camera3D":
		visible = false
