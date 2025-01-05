# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PhysicsEntity
extends RigidBody3D

@export var double_bounce_prevention_buffer_time: float = 1.0

var total_gravity: Vector3 = Vector3.ZERO

var _linear_velocity_prev: Vector3 = Vector3.ZERO
var _pending_bounces: Array[BounceArea] = []
var _pending_exact_velocities: PackedVector3Array = PackedVector3Array()
var _pending_minimum_velocities: PackedVector3Array = PackedVector3Array()
var _pending_forces: PackedVector3Array = PackedVector3Array()
var _pending_transform_offsets: PackedVector3Array = PackedVector3Array()

@onready var _bounce_shape_cast: ShapeCast3D = ShapeCast3D.new()
@onready var _bounce_area_timers: Dictionary = {}


func _ready() -> void:
	var collision_shape: CollisionShape3D = TreeUtils.get_collision_shape_for_body(self)
	assert(collision_shape != null, Errors.NULL_NODE)

	var shape: Shape3D = collision_shape.shape as Shape3D
	assert(shape != null, Errors.NULL_RESOURCE)

	_bounce_shape_cast.enabled = false
	_bounce_shape_cast.shape = shape
	assert(_bounce_shape_cast.shape != null)
	_bounce_shape_cast.collide_with_areas = true
	_bounce_shape_cast.collide_with_bodies = false
	_bounce_shape_cast.collision_mask = 256 # bounce layer
	add_child(_bounce_shape_cast)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Bounces
	perform_bounce_area_check(Vector3.ZERO, state.linear_velocity * state.step)

	for bounce_area: BounceArea in _pending_bounces:
		# Prevent double bounces on the same bounce area (either in the same physics frame, or in subsequent physics frames)
		@warning_ignore("unsafe_cast")
		var bounce_area_timer: SceneTreeTimer = _bounce_area_timers.get(bounce_area.get_path(), null) as SceneTreeTimer
		if bounce_area_timer != null and not is_zero_approx(bounce_area_timer.time_left):
			continue

		var bounce_normal: Vector3 = bounce_area.global_transform.basis.y
		var bounce_min_speed: float = bounce_area.bounce_min_speed
		var bounce_elasticity: float = bounce_area.bounce_elasticity
		assert(bounce_elasticity >= 0.0 and bounce_elasticity <= 1.0, Errors.INVALID_ARGUMENT)

		# Don't want bounce area to trigger from behind/below
		if bounce_normal.dot(global_position - bounce_area.global_position) <= 0.0:
			continue

		state.linear_velocity = _linear_velocity_prev.bounce(bounce_normal)
		var planar_velocity: Vector3 = Plane(bounce_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(bounce_normal)
		if bounce_elasticity * projected_velocity.length() < bounce_min_speed or projected_velocity.dot(bounce_normal) < 0.0:
			state.linear_velocity = bounce_min_speed * bounce_normal + planar_velocity
		else:
			state.linear_velocity = bounce_elasticity * projected_velocity + planar_velocity

		# Notify that body has bounced
		on_bounce(bounce_normal, bounce_min_speed, bounce_elasticity)
		bounce_area.on_body_bounced()

		# Clear pending velocities, forces and transform offsets (they are most likely no longer valid after a bounce)
		_pending_exact_velocities.clear()
		_pending_minimum_velocities.clear()
		_pending_forces.clear()
		_pending_transform_offsets.clear()

		# Create double bounce prevention timer)
		var timer: SceneTreeTimer = get_tree().create_timer(double_bounce_prevention_buffer_time, false, true, false)
		_bounce_area_timers[bounce_area.get_path()] = timer

		# Do not handle any more bounces (if any)
		break

	# Clear out stale bounce area timers
	var stale_bounce_area_timers: Array = _bounce_area_timers.keys() as Array
	for bounce_area_path: NodePath in _bounce_area_timers:
		var is_stale: bool = true
		for bounce_area: BounceArea in _pending_bounces:
			if bounce_area.get_path() == bounce_area_path:
				is_stale = false
				break
		if not is_stale:
			var n_prev: float = stale_bounce_area_timers.size()
			var i_delete: int = stale_bounce_area_timers.find(bounce_area_path)
			assert(i_delete >= 0, Errors.CONSISTENCY_ERROR)
			stale_bounce_area_timers.remove_at(i_delete)
			assert(stale_bounce_area_timers.size() == n_prev - 1, Errors.CONSISTENCY_ERROR)
	for stale_bounce_area_path: NodePath in stale_bounce_area_timers:
		var was_erased: bool = _bounce_area_timers.erase(stale_bounce_area_path)
		assert(was_erased, Errors.CONSISTENCY_ERROR)

	_pending_bounces.clear()

	# Exact velocity impulses
	for i: int in range(len(_pending_exact_velocities)):
		var impulse_velocity: Vector3 = _pending_exact_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		if not impulse_normal.is_normalized():
			push_error("impulse normal not normalized")
			continue

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		state.linear_velocity = impulse_velocity + planar_velocity
	_pending_exact_velocities.clear()

	# Minimum velocity impulses
	for i: int in range(len(_pending_minimum_velocities)):
		var impulse_velocity: Vector3 = _pending_minimum_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		if not impulse_normal.is_normalized():
			push_error("impulse normal not normalized")
			continue

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(impulse_normal)
		if projected_velocity.length() < impulse_velocity.length() or projected_velocity.dot(impulse_velocity) < 0.0:
			state.linear_velocity = impulse_velocity + planar_velocity
	_pending_minimum_velocities.clear()

	# Forces
	for i: int in range(len(_pending_forces)):
		var force_vector: Vector3 = _pending_forces[i]
		state.apply_central_force(force_vector)
	_pending_forces.clear()

	# Transform offsets
	for i: int in range(len(_pending_transform_offsets)):
		var offset: Vector3 = _pending_transform_offsets[i]
		state.transform.origin += offset
	_pending_transform_offsets.clear()

	_linear_velocity_prev = state.linear_velocity
	total_gravity = state.total_gravity


func perform_bounce_area_check(from: Vector3, to: Vector3) -> void:
	_bounce_shape_cast.position = from
	_bounce_shape_cast.target_position = to
	_bounce_shape_cast.force_shapecast_update()
	for i: int in range(_bounce_shape_cast.get_collision_count()):
		var bounce_area: BounceArea = _bounce_shape_cast.get_collider(i) as BounceArea
		if bounce_area != null:
			enqueue_bounce(bounce_area)


func enqueue_bounce(bounce_area: BounceArea) -> void:
	_pending_bounces.append(bounce_area)


func enqueue_exact_velocity(target_exact_velocity: Vector3) -> void:
	_pending_exact_velocities.append(target_exact_velocity)


func enqueue_minimum_velocity(target_minimum_velocity: Vector3) -> void:
	_pending_minimum_velocities.append(target_minimum_velocity)


func enqueue_force(force_vector: Vector3) -> void:
	_pending_forces.append(force_vector)


func enqueue_planar_force(force_vector: Vector2) -> void:
	enqueue_force(VectorUtils.vec2_to_vec3_xz(force_vector))


func enqueue_transform_offset(offset: Vector3) -> void:
	_pending_transform_offsets.append(offset)


# Virtual function
func on_bounce(_bounce_normal: Vector3, _bounce_min_speed: float, _bounce_elasticity: float) -> void:
	pass
