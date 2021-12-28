extends Control

@export var color_default: Color = Color.LIGHT_CORAL
@export var line_width: float = 5.0
@export var points_default: Array[Vector3]
@export var max_points_per_line: int = 1000

var lines: Dictionary
var colors: Dictionary


func _ready() -> void:
	Signals.visualize_line.connect(self._on_visualize_line)
	if points_default.size() > 0:
		assert(points_default.size() < max_points_per_line, Errors.INVALID_ARGUMENT)
		lines[null] = DataStructures.RotationQueue.new(max_points_per_line)
		for point in points_default:
			lines[null].add(point)
		colors[null] = color_default


func _draw() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	for sender in lines:
		var points = lines[sender]
		var color: Color = colors[sender]
		for iPoint in range(points.size() - 1):
			var p1: Vector3 = points.get_item(iPoint)
			var p2: Vector3 = points.get_item(iPoint + 1)
			if not camera.is_position_behind(p1) and not camera.is_position_behind(p2):
				draw_line(camera.unproject_position(p1), camera.unproject_position(p2), color, line_width)


func _process(_delta: float) -> void:
	update()


func _on_visualize_line(sender: Node, point: Vector3) -> void:
	visible = true
	if not lines.has(sender):
		lines[sender] = DataStructures.RotationQueue.new(max_points_per_line)
	lines[sender].add(point)
	if not colors.has(sender):
		colors[sender] = CColor.str_to_color(sender.name)
	update()
