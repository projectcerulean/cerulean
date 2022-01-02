class_name StateTransitionListener
extends Node

@export var _target_state: NodePath

@onready var target_state: State = get_node(_target_state) as State
@onready var target_state_machine: StateMachine = target_state.state_resource.state_machine


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)
	assert(target_state != null, Errors.NULL_NODE)
	assert(target_state_machine != null, Errors.NULL_NODE)
	assert(target_state in target_state_machine.get_children(), Errors.CONSISTENCY_ERROR)


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == target_state_machine and state == target_state:
		_on_target_state_entered()


func _on_state_exited(sender: Node, state: Node) -> void:
	if sender == target_state_machine and state == target_state:
		_on_target_state_exited()


# Override this
func _on_target_state_entered() -> void:
	pass


# Override this
func _on_target_state_exited() -> void:
	pass