extends StaticBody3D

@onready var crystal: Node3D = get_node("Crystal")


func _ready() -> void:
	assert(crystal != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	crystal.rotate_x(1.0 * delta)
	crystal.rotate_y(0.5 * delta)
	crystal.rotate_z(0.25 * delta)
