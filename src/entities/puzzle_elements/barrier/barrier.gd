extends StaticBody3D

@export var input_nodes: Array[NodePath]
@export var target_states: Array[bool]

var input_states: Array[bool]

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D")


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(len(input_nodes) == len(target_states), Errors.INVALID_ARGUMENT)
	assert(collision_shape != null, Errors.NULL_NODE)

	input_states.resize(len(target_states))


func _on_state_entered(sender: Node, state: Node) -> void:
	for i in range(len(input_states)):
		if sender == get_node(input_nodes[i]).state_machine:
			input_states[i] = bool(state.get_index())

	var requirements_satisfied: bool = input_states == target_states
	collision_shape.disabled = requirements_satisfied
	visible = !requirements_satisfied
