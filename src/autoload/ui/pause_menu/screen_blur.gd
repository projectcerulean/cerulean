extends ColorRect

@export var game_state: Resource


func _ready():
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().state_entered.get_name(), self._on_state_entered)
	SignalsGetter.get_signals().connect(SignalsGetter.get_signals().state_exited.get_name(), self._on_state_exited)

	assert(game_state as StateResource != null)


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == game_state.state_machine and state == game_state.states.PAUSE:
		visible = true


func _on_state_exited(sender: Node, state: Node) -> void:
	if sender == game_state.state_machine and state == game_state.states.PAUSE:
		visible = false
