extends Control

@export var color: Color = Color.WHITE
@export var _lfo_resource: Resource
@export var _game_state_resource: Resource
@export var oscillation_amplitude: float = 128.0
@export var scale_factor_min: float = 0.25
@export var tween_time: float = 1.0
@export var polygon_shape: PackedVector2Array = PackedVector2Array([
	Vector2(-128.0, -128.0),
	Vector2(128.0, -128.0),
	Vector2(0.0, 0.0),
])

var scale_factor: float = 1.0
var target: Node3D = null

@onready var color_default: Color = color
@onready var tween: Tween
@onready var lfo_resource: LfoResource = _lfo_resource as LfoResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource


func _ready() -> void:
	Signals.interaction_highlight_set.connect(self._on_interaction_highlight_set)
	Signals.request_interaction.connect(self._on_request_interaction)
	assert(lfo_resource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)


func _draw() -> void:
	if game_state_resource.current_state != GameStates.GAMEPLAY:
		return

	if target == null:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var position3d: Vector3 = target.global_transform.origin
	if not camera.is_position_behind(position3d):
		var position2d: Vector2 = camera.unproject_position(position3d)
		var camera_distance: float = (camera.global_transform.origin - position3d).length()
		var vertex_positions: PackedVector2Array = PackedVector2Array(polygon_shape)
		for i in range(vertex_positions.size()):
			vertex_positions[i] *= scale_factor
			vertex_positions[i] /= camera_distance
			vertex_positions[i] += position2d - Vector2(0.0, oscillation_amplitude * abs(lfo_resource.value_fourth_shifted) / camera_distance)
		draw_polygon(vertex_positions, PackedColorArray([color, color, color]))


func _process(_delta: float) -> void:
	update()


func _on_interaction_highlight_set(_sender: Node, highlight_target: Node3D) -> void:
	if highlight_target != null and highlight_target != target:
		animate()
	target = highlight_target


func _on_request_interaction(_sender: Node) -> void:
	if target != null:
		animate()


func animate() -> void:
	scale_factor = scale_factor_min
	color = Color.WHITE
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale_factor", 1.0, tween_time)
	tween.parallel().set_trans(Tween.TRANS_QUINT)
	tween.parallel().set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "color", color_default, tween_time)
