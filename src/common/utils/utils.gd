class_name Utils
extends Node


static func calculate_shape_volume(shape: Shape3D) -> float:
	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape as BoxShape3D
		return box_shape.size.x * box_shape.size.y * box_shape.size.z
	else:
		# Not implemented
		return NAN


static func get_collision_shape_for_area(area: Area3D) -> CollisionShape3D:
	var collision_shape: CollisionShape3D = null
	for child in area.get_children():
		if child as CollisionShape3D != null:
			collision_shape = child
			break
	return collision_shape


static func get_collision_shape_for_body(body: PhysicsBody3D) -> CollisionShape3D:
	var collision_shape: CollisionShape3D = null
	for child in body.get_children():
		if child as CollisionShape3D != null:
			collision_shape = child
			break
	return collision_shape
