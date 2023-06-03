# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PhysicsEntity
extends RigidBody3D

const EPSILON: float = 0.01

@export var transform_inheritence_enabled: bool = false
@export var floor_snapping_enabled: bool = false
@export var floor_max_angle: float = PI / 4.0
@export var floor_collision_check_length: float = 0.25
@export var floor_snap_min_distance: float = 0.01
@export var floor_snap_max_distance: float = floor_collision_check_length
@export var floor_snap_lerp_weight: float = 0.95
@export var shape_cast_scale: float = 0.95

var shape_cast_i_floor_collision: int = -1
var ray_cast_floor_collision = false
var floor_velocity_prober_position_prev: Vector3
var linear_velocity_prev: Vector3 = Vector3.ZERO
var pending_impulse_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_elasticities: PackedFloat64Array = PackedFloat64Array()
var pending_forces: PackedVector3Array = PackedVector3Array()
var shape: Shape3D = null

@onready var floor_velocity_prober: Node3D = Node3D.new()
@onready var ray_cast: RayCast3D = RayCast3D.new()
@onready var shape_cast: ShapeCast3D = ShapeCast3D.new()
@onready var shape_cast_target_position: Vector3 = Vector3.DOWN * floor_collision_check_length


func _ready() -> void:
	Signals.request_body_bounce.connect(_on_request_body_bounce)

	var collision_shape: CollisionShape3D = null
	for i in range(get_child_count()):
		var child: Node = get_child(i)
		collision_shape = child as CollisionShape3D
		if collision_shape != null:
			break
	assert(collision_shape != null, Errors.NULL_NODE)

	shape = collision_shape.shape
	assert(shape != null, Errors.NULL_RESOURCE)

	shape_cast.shape = ShapeUtils.get_shape_scaled_xy(shape, shape_cast_scale)
	shape_cast.target_position = shape_cast_target_position
	shape_cast.collision_mask = collision_mask
	shape_cast.position.y = shape_cast.shape.margin + EPSILON
	add_child(shape_cast)

	ray_cast.target_position = Vector3.DOWN * (ShapeUtils.get_shape_height(shape) / 2.0 + floor_collision_check_length)
	ray_cast.collision_mask = collision_mask
	add_child(ray_cast)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Impulses
	for i in range(len(pending_impulse_velocities)):
		var impulse_velocity: Vector3 = pending_impulse_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		if not impulse_normal.is_normalized():
			push_error("impulse normal not normalized")
			continue

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(impulse_normal)
		if projected_velocity.length() < impulse_velocity.length() or projected_velocity.dot(impulse_velocity) < 0.0:
			state.linear_velocity = impulse_velocity + planar_velocity
	pending_impulse_velocities.clear()

	# Bounces
	for i in range(len(pending_bounce_velocities)):
		var bounce_velocity: Vector3 = pending_bounce_velocities[i]
		var bounce_normal: Vector3 = bounce_velocity.normalized()
		if not bounce_normal.is_normalized():
			push_error("bounce normal not normalized")
			continue

		var elasticy: float = pending_bounce_elasticities[i]
		assert(elasticy >= 0.0 and elasticy <= 1.0, Errors.INVALID_ARGUMENT)

		state.linear_velocity = linear_velocity_prev.bounce(bounce_normal)
		var planar_velocity: Vector3 = Plane(bounce_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(bounce_normal)
		if elasticy * projected_velocity.length() < bounce_velocity.length() or projected_velocity.dot(bounce_velocity) < 0.0:
			state.linear_velocity = bounce_velocity + planar_velocity
		else:
			state.linear_velocity = elasticy * projected_velocity + planar_velocity
	pending_bounce_velocities.clear()
	pending_bounce_elasticities.clear()

	# Forces
	for i in range(len(pending_forces)):
		var force_vector: Vector3 = pending_forces[i]
		state.apply_central_force(force_vector)
	pending_forces.clear()

	# Find floor collider using shapecast
	shape_cast_i_floor_collision = -1
	shape_cast.force_shapecast_update()
	if shape_cast.is_colliding():
		for i_collision in range(shape_cast.get_collision_count()):
			var is_below_entity: bool = shape_cast.get_collision_point(i_collision).y < global_position.y
			var is_floor: bool = shape_cast.get_collision_normal(i_collision).angle_to(Vector3.UP) <= floor_max_angle
			if is_below_entity and is_floor:
				var floor_collider: Node3D = shape_cast.get_collider(i_collision) as Node3D
				if floor_collider != null:
					if (
						shape_cast_i_floor_collision < 0
						or shape_cast.get_collision_point(i_collision) > shape_cast.get_collision_point(shape_cast_i_floor_collision)
					):
						shape_cast_i_floor_collision = i_collision

	# Find floor collider using raycast (shape cast is sometimes unreliable)
	ray_cast_floor_collision = false
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var is_below_entity: bool = ray_cast.get_collision_point().y < global_position.y
		var is_floor: bool = ray_cast.get_collision_normal().angle_to(Vector3.UP) <= floor_max_angle
		if is_below_entity and is_floor:
			ray_cast_floor_collision = true

	# Apply floor transform
	var node_reparented: bool = TreeUtils.reparent_node(
		floor_velocity_prober,
		get_floor_collider() if get_floor_collider() != null else self
	)

	var prober_parent: Node3D = floor_velocity_prober.get_parent() as Node3D
	if transform_inheritence_enabled and prober_parent != null and prober_parent != self and not node_reparented:
		state.transform.origin += floor_velocity_prober.global_position - floor_velocity_prober_position_prev
		floor_velocity_prober.global_position = get_floor_collision_position()

	if floor_snapping_enabled:
		var floor_distance: float = get_floor_distance()
		if not is_nan(floor_distance):
			if floor_distance > floor_snap_min_distance and floor_distance < floor_snap_max_distance:
				var origin_before: Vector3 = state.transform.origin
				state.transform.origin.y -= floor_distance * floor_snap_lerp_weight

	floor_velocity_prober_position_prev = floor_velocity_prober.global_position

	linear_velocity_prev = state.linear_velocity


func enqueue_impulse(target_velocity: Vector3):
	pending_impulse_velocities.append(target_velocity)


func enqueue_bounce(bounce_velocity: Vector3, elasticy: float):
	pending_bounce_velocities.append(bounce_velocity)
	pending_bounce_elasticities.append(elasticy)


func enqueue_force(force_vector: Vector3):
	pending_forces.append(force_vector)


func _on_request_body_bounce(_sender: Node, body: Node3D, target_velocity: Vector3, elasticy: float) -> void:
	if body == self:
		enqueue_bounce(target_velocity, elasticy)


func is_on_floor() -> bool:
	var floor_distance: float = get_floor_distance()
	return not is_nan(floor_distance) and floor_distance < floor_snap_min_distance


func is_near_floor() -> bool:
	return not is_nan(get_floor_distance())


func get_floor_normal() -> Vector3:
	if shape_cast_i_floor_collision >= 0:
		return shape_cast.get_collision_normal(shape_cast_i_floor_collision)
	elif ray_cast_floor_collision:
		return ray_cast.get_collision_normal()
	else:
		return Vector3.ZERO


func get_floor_collision_position() -> Vector3:
	if shape_cast_i_floor_collision >= 0:
		return shape_cast.get_collision_point(shape_cast_i_floor_collision)
	elif ray_cast_floor_collision:
		return ray_cast.get_collision_point()
	else:
		return Vector3.ZERO


func get_floor_collider() -> Node3D:
	if shape_cast_i_floor_collision >= 0:
		return shape_cast.get_collider(shape_cast_i_floor_collision) as Node3D
	elif ray_cast_floor_collision:
		return ray_cast.get_collider() as Node3D
	else:
		return null


func get_floor_distance() -> float:
	if shape_cast_i_floor_collision >= 0:
		var collision_distance: float = (shape_cast.get_closest_collision_safe_fraction() * shape_cast_target_position).length()
		var floor_distance: float = collision_distance - shape_cast.position.y
		return floor_distance
	elif ray_cast_floor_collision:
		var collision_distance: float = (ray_cast.get_collision_point() - ray_cast.global_position).length()
		var floor_distance: float = collision_distance - ShapeUtils.get_shape_height(shape) / 2.0
		return floor_distance
	else:
		return NAN
