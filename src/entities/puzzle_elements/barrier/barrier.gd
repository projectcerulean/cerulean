class_name Barrier
extends StaticBody3D

@export var input_nodes: Array[NodePath]
@export var input_targets: Array[bool]
@export var fade_duration: float = 0.25

var inputs: Array[bool]

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")
@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D")
@onready var state_machine: Node = get_node("StateMachine")
@onready var tween: Tween = create_tween()
@onready var shader_material: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(len(input_nodes) == len(input_targets), Errors.INVALID_ARGUMENT)
	assert(collision_shape != null, Errors.NULL_NODE)
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(shader_material != null, Errors.NULL_RESOURCE)

	inputs.resize(len(input_targets))


func _on_state_entered(sender: Node, state: StringName) -> void:
	for i in range(len(inputs)):
		if sender.owner == get_node(input_nodes[i]):
			assert(state in [PuzzleElementStates.DISABLED, PuzzleElementStates.ENABLED], Errors.CONSISTENCY_ERROR)
			inputs[i] = state == PuzzleElementStates.ENABLED

	if inputs == input_targets:
		Signals.emit_request_state_change(self, state_machine, PuzzleElementStates.DISABLED)
	else:
		Signals.emit_request_state_change(self, state_machine, PuzzleElementStates.ENABLED)


func set_alpha(alpha: float) -> void:
	shader_material.set_shader_param("alpha_factor", alpha)
