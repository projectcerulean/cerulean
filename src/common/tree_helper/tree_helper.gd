class_name TreeHelper
extends Node


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
