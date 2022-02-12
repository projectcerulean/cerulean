class_name Indicator
extends Node3D

@export var input_node_path: NodePath

@onready var input_node: Node = get_node(input_node_path) as Node
@onready var state_machine: Node = get_node("StateMachine") as Node


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(input_node != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(state_machine.get_child_count() == 2, Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender.owner == input_node:
		Signals.emit_request_state_change(self, state_machine, state)
