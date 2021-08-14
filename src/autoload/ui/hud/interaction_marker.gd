extends Control

@export var color: Color = Color.WHITE
@export var lfo_resource: Resource
@export var game_state_resource: Resource
@export var oscillation_amplitude: float = 128.0
@export var polygon_shape: PackedVector2Array = PackedVector2Array([
	Vector2(-128.0, -128.0),
	Vector2(128.0, -128.0),
	Vector2(0.0, 0.0),
])

var target: Node3D = null

@onready var color_array: PackedColorArray = PackedColorArray([color, color, color])


func _ready() -> void:
	SignalsGetter.get_signals().interaction_highlight_set.connect(self._on_interaction_highlight_set)
	assert(lfo_resource as LfoResource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource as StateResource != null, Errors.NULL_RESOURCE)


func _draw() -> void:
	if game_state_resource.state != game_state_resource.states.GAMEPLAY:
		return

	if target == null:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var position3d: Vector3 = target.global_transform.origin
	if not camera.is_position_behind(position3d):
		var position2d = camera.unproject_position(position3d)
		var camera_distance = (camera.global_transform.origin - position3d).length()
		var vertex_positions: PackedVector2Array = PackedVector2Array(polygon_shape)
		for i in range(vertex_positions.size()):
			vertex_positions[i] /= camera_distance
			vertex_positions[i] += position2d - Vector2(0.0, oscillation_amplitude * abs(lfo_resource.valueFourthShifted) / camera_distance)
		draw_polygon(vertex_positions, color_array)


func _process(_delta: float) -> void:
	update()


func _on_interaction_highlight_set(sender: Node, target: Node3D):
	self.target = target
