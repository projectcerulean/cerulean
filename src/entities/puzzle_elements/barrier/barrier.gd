class_name Barrier
extends StaticBody3D

@export var input_nodes: Array[NodePath]
@export var input_targets: Array[bool]
@export var fade_duration: float = 0.25

var inputs: Array[bool]

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")
@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D")
@onready var state_machine: StateMachine = get_node("StateMachine")
@onready var tween: Tween = create_tween()


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(len(input_nodes) == len(input_targets), Errors.INVALID_ARGUMENT)
	assert(collision_shape != null, Errors.NULL_NODE)
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)

	inputs.resize(len(input_targets))


func _on_state_entered(sender: Node, state: Node) -> void:
	for i in range(len(inputs)):
		if sender == get_node(input_nodes[i]).state_machine:
			inputs[i] = bool(state.get_index())

	var requirements_satisfied: bool = inputs == input_targets
	var target_state: BarrierState = state_machine.get_children()[int(!requirements_satisfied)]
	state_machine.lazy_transition_to(target_state)


func set_alpha(alpha: float) -> void:
	mesh_instance.get_surface_override_material(0).set_shader_param("alpha_factor", alpha)
