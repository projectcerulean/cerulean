class_name Line3D
extends Node2D

@export var camera_path: NodePath
@export var color: Color = Color.RED
@export var line_width: float = 5.0

@onready var camera: Camera3D = get_node(camera_path)

@export var points: Array[Vector3]


func _ready() -> void:
	if camera == null:
		camera = get_viewport().get_camera()
	assert(camera != null)


func _draw():
	for iPoint in range(points.size() - 1):
		if not camera.is_position_behind(points[iPoint]) and not camera.is_position_behind(points[iPoint + 1]):
			draw_line(camera.unproject_position(points[iPoint]), camera.unproject_position(points[iPoint + 1]), color, line_width)


func _process(delta):
	update()


func add_point(point: Vector3):
	points.append(point)
