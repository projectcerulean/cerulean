extends Control

@export var text_reveal_speed: float = 180.0
@export var dialogue_resource: Resource
@export var game_state: Resource

var line_index: int = 0

@onready var label: Label = get_node("Label")
@onready var state_machine: Node = get_node("StateMachine")


func _ready() -> void:
	SignalsGetter.get_signals().request_dialogue_start.connect(self._on_request_dialogue_start)
	SignalsGetter.get_signals().state_entered.connect(self._on_state_entered)
	SignalsGetter.get_signals().state_exited.connect(self._on_state_exited)

	assert(label != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)
	assert(dialogue_resource as DialogueResource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_request_dialogue_start(sender: Node3D, dialogue_resource_new: DialogueResource) -> void:
	assert(dialogue_resource_new != null, Errors.NULL_RESOURCE)
	dialogue_resource = dialogue_resource_new
	line_index = -1


func _on_request_dialogue_finish(sender: Node) -> void:
	dialogue_resource = null


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == game_state.state_machine and state == game_state.states.DIALOGUE:
		state_machine.transition_to(state_machine.state.states.OUTPUT)
		self.visible = true


func _on_state_exited(sender: Node, state: Node) -> void:
	if sender == game_state.state_machine and state == game_state.states.DIALOGUE:
		self.visible = false
