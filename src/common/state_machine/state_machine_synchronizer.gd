extends Node

@export var _state_machine_parent: NodePath
@export var _state_machine_child: NodePath

@onready var state_machine_parent = get_node(_state_machine_parent) as Node
@onready var state_machine_child = get_node(_state_machine_child) as Node


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)

	assert(state_machine_parent != null, Errors.NULL_NODE)
	assert(state_machine_child != null, Errors.NULL_NODE)
	assert(state_machine_parent.get_child_count() > 0, Errors.CONSISTENCY_ERROR)
	assert(state_machine_child.get_child_count() == state_machine_parent.get_child_count(), Errors.CONSISTENCY_ERROR)
	for i in range(state_machine_parent.get_child_count()):
		assert(state_machine_child.get_child(i).name == state_machine_parent.get_child(i).name, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: Node, state: StringName):
	if sender == state_machine_parent:
		Signals.emit_request_state_change(self, state_machine_child, state)
