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
var pending_exact_velocities: PackedVector3Array = PackedVector3Array()
var pending_minimum_velocities: PackedVector3Array = PackedVector3Array()
var pending_forces: PackedVector3Array = PackedVector3Array()
var shape: Shape3D = null

@onready var floor_velocity_prober: Node3D = Node3D.new()
@onready var ray_cast: RayCast3D = RayCast3D.new()
@onready var shape_cast: ShapeCast3D = ShapeCast3D.new()
@onready var shape_cast_target_position: Vector3 = Vector3.DOWN * floor_collision_check_length
@onready var bounce_shape_cast: ShapeCast3D = ShapeCast3D.new()


func _ready() -> void:
	var collision_shape: CollisionShape3D = TreeUtils.get_collision_shape_for_body(self)
	assert(collision_shape != null, Errors.NULL_NODE)

	shape = collision_shape.shape
	assert(shape != null, Errors.NULL_RESOURCE)

	shape_cast.shape = ShapeUtils.get_shape_scaled_xz(shape, shape_cast_scale)
	shape_cast.target_position = shape_cast_target_position
	shape_cast.collision_mask = collision_mask
	shape_cast.position.y = shape_cast.shape.margin + EPSILON
	add_child(shape_cast)

	ray_cast.target_position = Vector3.DOWN * (ShapeUtils.get_shape_height(shape) / 2.0 + floor_collision_check_length)
	ray_cast.collision_mask = collision_mask
	add_child(ray_cast)

	bounce_shape_cast.shape = shape
	bounce_shape_cast.collide_with_areas = true
	bounce_shape_cast.collide_with_bodies = false
	bounce_shape_cast.collision_mask = 256 # bounce layer
	add_child(bounce_shape_cast)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Bounces
	bounce_shape_cast.target_position = state.linear_velocity * state.step
	bounce_shape_cast.force_shapecast_update()
	for i in range(bounce_shape_cast.get_collision_count()):
		var bounce_area: BounceArea = bounce_shape_cast.get_collider(i) as BounceArea
		if bounce_area != null:
			var bounce_normal: Vector3 = bounce_area.global_transform.basis.y
			var bounce_min_speed: float = bounce_area.bounce_min_speed
			var bounce_elasticity: float = bounce_area.bounce_elasticity
			assert(bounce_elasticity >= 0.0 and bounce_elasticity <= 1.0, Errors.INVALID_ARGUMENT)

			# Don't want bounce area to trigger from behind/below
			if bounce_normal.dot(global_position - bounce_area.global_position) <= 0.0:
				continue

			state.linear_velocity = linear_velocity_prev.bounce(bounce_normal)
			var planar_velocity: Vector3 = Plane(bounce_normal).project(state.linear_velocity)
			var projected_velocity: Vector3 = state.linear_velocity.project(bounce_normal)
			if bounce_elasticity * projected_velocity.length() < bounce_min_speed or projected_velocity.dot(bounce_normal) < 0.0:
				state.linear_velocity = bounce_min_speed * bounce_normal + planar_velocity
			else:
				state.linear_velocity = bounce_elasticity * projected_velocity + planar_velocity

			# Notify that body has bounced
			on_bounce(bounce_normal, bounce_min_speed, bounce_elasticity)
			bounce_area.on_body_bounced()

			# Clear pending velocities and forces (they are most likely no longer valid after a bounce)
			pending_exact_velocities.clear()
			pending_minimum_velocities.clear()
			pending_forces.clear()

			# Do not handle any more bounces (if any)
			break

	# Exact velocity impulses
	for i in range(len(pending_exact_velocities)):
		var impulse_velocity: Vector3 = pending_exact_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		if not impulse_normal.is_normalized():
			push_error("impulse normal not normalized")
			continue

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		state.linear_velocity = impulse_velocity + planar_velocity
	pending_exact_velocities.clear()

	# Minimum velocity impulses
	for i in range(len(pending_minimum_velocities)):
		var impulse_velocity: Vector3 = pending_minimum_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		if not impulse_normal.is_normalized():
			push_error("impulse normal not normalized")
			continue

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(impulse_normal)
		if projected_velocity.length() < impulse_velocity.length() or projected_velocity.dot(impulse_velocity) < 0.0:
			state.linear_velocity = impulse_velocity + planar_velocity
	pending_minimum_velocities.clear()

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
				state.transform.origin.y -= floor_distance * floor_snap_lerp_weight

	floor_velocity_prober_position_prev = floor_velocity_prober.global_position

	linear_velocity_prev = state.linear_velocity


func enqueue_exact_velocity(target_exact_velocity: Vector3):
	pending_exact_velocities.append(target_exact_velocity)


func enqueue_minimum_velocity(target_minimum_velocity: Vector3):
	pending_minimum_velocities.append(target_minimum_velocity)


func enqueue_force(force_vector: Vector3):
	pending_forces.append(force_vector)


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


# Virtual function
func on_bounce(_bounce_normal: Vector3, _bounce_min_speed: float, _bounce_elasticity: float):
	pass
