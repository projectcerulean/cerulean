class_name StateTransitionListener
extends Node

@export var _target_state: NodePath

var is_in_target_state: bool = false

@onready var target_state: Node = get_node(_target_state) as Node
@onready var target_state_machine: Node = target_state.get_parent() as Node


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)
	assert(target_state != null, Errors.NULL_NODE)
	assert(target_state_machine != null, Errors.NULL_NODE)
	assert(target_state in target_state_machine.get_children(), Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: Node, state: StringName, _data: Dictionary) -> void:
	if sender == target_state_machine and state == target_state.name:
		is_in_target_state = true
		_on_target_state_entered()


func _on_state_exited(sender: Node, state: StringName, _data: Dictionary) -> void:
	if sender == target_state_machine and state == target_state.name:
		is_in_target_state = false
		_on_target_state_exited()


# Override this
func _on_target_state_entered() -> void:
	pass


# Override this
func _on_target_state_exited() -> void:
	pass
