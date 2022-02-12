class_name PauseMenu
extends Control

@export var _game_state_resource: Resource
@export var _sfx_resource_select: Resource
@export var scene_transition_color: Color = Color.WHITE_SMOKE
@export var scene_transition_fade_duration: float = 0.5

@onready var game_state_resource: StateResource = _game_state_resource as StateResource
@onready var sfx_resource_select: SfxResource = _sfx_resource_select as SfxResource


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	assert(sfx_resource_select != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.PAUSE:
		self.visible = true


func _on_state_exited(sender: Node, state: StringName) -> void:
	if sender == game_state_resource.state_machine and state == GameStates.PAUSE:
		self.visible = false
