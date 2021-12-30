class_name Switch
extends StaticBody3D

@onready var crystal: Node3D = get_node("Crystal")
@onready var state_machine: StateMachine = get_node("StateMachine")


func _ready() -> void:
	assert(crystal != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)

func flip():
	state_machine.transition_to_next()
