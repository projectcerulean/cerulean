extends Control

@export var game_state_resource: Resource
@export var sfx_resource_select: Resource


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	Signals.state_exited.connect(self._on_state_exited)

	assert(game_state_resource as StateResource != null, Errors.NULL_RESOURCE)
	assert(sfx_resource_select as SfxResource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == game_state_resource.state_machine and state == game_state_resource.states.PAUSE:
		self.visible = true


func _on_state_exited(sender: Node, state: Node) -> void:
	if sender == game_state_resource.state_machine and state == game_state_resource.states.PAUSE:
		self.visible = false
