extends Node

signal area_area_entered
signal area_area_exited
signal area_body_entered
signal area_body_exited
signal debug_write
signal state_entered
signal state_exited
signal visualize_line
signal visualize_vector


func emit_area_area_entered(sender: Area3D, area: Area3D) -> void:
	call_deferred("emit_signal", area_area_entered.get_name(), sender, area)


func emit_area_area_exited(sender: Area3D, area: Area3D) -> void:
	call_deferred("emit_signal", area_area_exited.get_name(), sender, area)


func emit_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void:
	call_deferred("emit_signal", area_body_entered.get_name(), sender, body)


func emit_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void:
	call_deferred("emit_signal", area_body_exited.get_name(), sender, body)


func emit_debug_write(sender: Node, variant: Variant) -> void:
	call_deferred("emit_signal", debug_write.get_name(), sender, variant)


func emit_state_entered(sender: Node, state_name: String) -> void:
	call_deferred("emit_signal", state_entered.get_name(), sender, state_name)


func emit_state_exited(sender: Node, state_name: String) -> void:
	call_deferred("emit_signal", state_exited.get_name(), sender, state_name)


func emit_visualize_line(sender: Node, point: Vector3) -> void:
	call_deferred("emit_signal", visualize_line.get_name(), sender, point)


func emit_visualize_vector(sender: Node, vector: Vector2) -> void:
	call_deferred("emit_signal", visualize_vector.get_name(), sender, vector)
