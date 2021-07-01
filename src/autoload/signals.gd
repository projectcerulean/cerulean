extends Node

signal debug_write
signal state_entered
signal state_exited


func emit_debug_write(sender: Node, string: String) -> void:
	call_deferred("emit_signal", debug_write.get_name(), sender, string)


func emit_state_entered(sender: Node, state_name: String) -> void:
	call_deferred("emit_signal", state_entered.get_name(), sender, state_name)


func emit_state_exited(sender: Node, state_name: String) -> void:
	call_deferred("emit_signal", state_exited.get_name(), sender, state_name)
