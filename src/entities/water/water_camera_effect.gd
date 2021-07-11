extends ColorRect

@export var camera_path: NodePath

@onready var camera: Camera3D = get_node(camera_path)


func _ready():
	Signals.connect(Signals.area_area_entered.get_name(), self._on_area_area_entered_exited)
	Signals.connect(Signals.area_area_exited.get_name(), self._on_area_area_entered_exited)

	assert(camera != null)


func _on_area_area_entered_exited(sender: Area3D, area: Area3D):
	visible = camera.is_in_water()
