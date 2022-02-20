class_name Switch
extends StaticBody3D

@onready var state_machine: Node = get_node("StateMachine") as Node


func _ready() -> void:
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)

func flip() -> void:
	Signals.emit_request_state_change_next(self, state_machine)
