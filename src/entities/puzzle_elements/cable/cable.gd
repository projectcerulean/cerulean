class_name Cable
extends MeshInstance3D

@export var input_node_path: NodePath
@export var flow_speed: float = 50.0

@onready var box_mesh: BoxMesh = mesh as BoxMesh
@onready var shader_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial
@onready var flow_position_start: float = -box_mesh.size.y / 4.0 - shader_material.get_shader_param("smooth_range") / 2.0
@onready var flow_position_end: float = -flow_position_start
@onready var flow_duration: float = abs(flow_position_end - flow_position_start) / flow_speed
@onready var state_next: StringName

@onready var state_machine: Node = get_node("StateMachine")
@onready var input_node: Node = get_node(input_node_path)
@onready var tween: Tween = create_tween()


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(box_mesh != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(input_node != null, Errors.NULL_NODE)

	shader_material.set_shader_param("flip_colors", state_next)
	set_flow_position(flow_position_start)


func set_flow_position(flow_position: float) -> void:
	shader_material.set_shader_param("flow_position", flow_position)


func tween_callback() -> void:
	Signals.emit_request_state_change(self, state_machine, state_next)


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender.owner == input_node:
		state_next = state
		var flip_colors: bool = state_next == PuzzleElementStates.DISABLED
		shader_material.set_shader_param("flip_colors", flip_colors)
		set_flow_position(flow_position_start)

		tween.kill()
		tween = create_tween()
		tween.tween_method(set_flow_position, flow_position_start, flow_position_end, flow_duration)
		tween.tween_callback(tween_callback)
