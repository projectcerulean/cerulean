extends Node3D

@onready var decal_pivot: Node3D = get_node("DecalPivot") as Node3D
@onready var raycast: RayCast3D = get_node("RayCast3D") as RayCast3D


func _ready() -> void:
	assert(decal_pivot != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	if raycast.is_colliding():
		var up_direction: Vector3 = Vector3.RIGHT if raycast.get_collision_normal().is_equal_approx(Vector3.UP) else Vector3.UP
		decal_pivot.look_at_from_position(raycast.get_collision_point(), raycast.get_collision_point() + raycast.get_collision_normal(), up_direction)
		decal_pivot.visible = true
	else:
		decal_pivot.visible = false
