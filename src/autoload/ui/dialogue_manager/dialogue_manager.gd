extends Control

@export var text_reveal_speed: float = 180.0
@export var _game_state_resource: Resource

var dialogue_resource: Resource = null
var line_index: int = 0

@onready var label: Label = get_node("Label")
@onready var state_machine: Node = get_node("StateMachine")
@onready var game_state_resource: StateResource = _game_state_resource as StateResource


func _ready() -> void:
	Signals.request_dialogue_start.connect(self._on_request_dialogue_start)
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(label != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_request_dialogue_start(_sender: Node3D, dialogue_resource_new: DialogueResource) -> void:
	assert(dialogue_resource_new != null, Errors.NULL_RESOURCE)
	dialogue_resource = dialogue_resource_new
	line_index = -1


func _on_request_dialogue_finish(_sender: Node) -> void:
	dialogue_resource = null


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.DIALOGUE:
		Signals.emit_request_state_change(self, state_machine, DialogueStates.OUTPUT)
		self.visible = true


func _on_state_exited(sender: Node, state: StringName) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.DIALOGUE:
		self.visible = false
