extends Control

@export var game_state: Resource


func _ready() -> void:
	SignalsGetter.get_signals().state_entered.connect(self._on_state_entered)
	SignalsGetter.get_signals().state_exited.connect(self._on_state_exited)

	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)
	self.visible = false


func _on_state_entered(sender: Node, state: Node):
	if sender == game_state.state_machine and state == game_state.states.PAUSE:
		self.visible = true


func _on_state_exited(sender: Node, state: Node):
	if sender == game_state.state_machine and state == game_state.states.PAUSE:
		self.visible = false
