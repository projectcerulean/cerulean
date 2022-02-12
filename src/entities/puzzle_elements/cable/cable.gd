class_name Cable
extends MeshInstance3D

@export var input_node_path: NodePath
@export var flow_speed: float = 50.0

@onready var flow_position_start: float = -mesh.size.y / 4.0 - get_surface_override_material(0).get_shader_param("smooth_range") / 2.0
@onready var flow_position_end: float = -flow_position_start
@onready var flow_duration: float = abs(flow_position_end - flow_position_start) / flow_speed
@onready var state_next: StringName

@onready var state_machine: Node = get_node("StateMachine")
@onready var input_node: Node = get_node(input_node_path)
@onready var tween: Tween = create_tween()


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(input_node != null, Errors.NULL_NODE)

	get_surface_override_material(0).set_shader_param("flip_colors", state_next)
	set_flow_position(flow_position_start)


func set_flow_position(flow_position: float) -> void:
	get_surface_override_material(0).set_shader_param("flow_position", flow_position)


func tween_callback() -> void:
	Signals.emit_request_state_change(self, state_machine, state_next)


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender.owner == input_node:
		state_next = state
		var flip_colors: bool = state_next == PuzzleElementStates.DISABLED
		get_surface_override_material(0).set_shader_param("flip_colors", flip_colors)
		set_flow_position(flow_position_start)

		tween.kill()
		tween = create_tween()
		tween.tween_method(set_flow_position, flow_position_start, flow_position_end, flow_duration)
		tween.tween_callback(tween_callback)
