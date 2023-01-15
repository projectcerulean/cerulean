# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PhysicsEntity
extends RigidBody3D

@export var transform_inheritence_enabled: bool = false
@export var floor_snapping_enabled: bool = false
@export var floor_max_angle: float = PI / 4.0
@export var floor_collision_check_length: float = 0.1

var floor_collision: KinematicCollision3D = null
var floor_velocity_prober_position_prev: Vector3
var linear_velocity_prev: Vector3 = Vector3.ZERO
var pending_impulse_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_elasticities: PackedFloat64Array = PackedFloat64Array()
var pending_forces: PackedVector3Array = PackedVector3Array()

@onready var floor_velocity_prober: Node3D = Node3D.new()


func _ready() -> void:
	Signals.request_body_bounce.connect(_on_request_body_bounce)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Impulses
	for i in range(len(pending_impulse_velocities)):
		var impulse_velocity: Vector3 = pending_impulse_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		assert(impulse_normal.is_normalized(), Errors.CONSISTENCY_ERROR)

		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(impulse_normal)
		if projected_velocity.length() < impulse_velocity.length() or projected_velocity.dot(impulse_velocity) < 0.0:
			state.linear_velocity = impulse_velocity + planar_velocity
	pending_impulse_velocities.clear()

	# Bounces
	for i in range(len(pending_bounce_velocities)):
		var bounce_velocity: Vector3 = pending_bounce_velocities[i]
		var bounce_normal: Vector3 = bounce_velocity.normalized()
		assert(bounce_normal.is_normalized(), Errors.CONSISTENCY_ERROR)

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

	# Apply floor transform
	floor_collision = null
	var collision: KinematicCollision3D = KinematicCollision3D.new()
	if test_move(global_transform, floor_collision_check_length * Vector3.DOWN, collision):
		if collision.get_position().y < global_position.y and collision.get_angle() <= floor_max_angle:
			floor_collision = collision

	var node_reparented: bool = Utils.reparent_node(
		floor_velocity_prober,
		floor_collision.get_collider() if floor_collision != null else self
	)

	var prober_parent: Node3D = floor_velocity_prober.get_parent() as Node3D
	if transform_inheritence_enabled and prober_parent != null and prober_parent != self and not node_reparented:
		state.transform.origin += floor_velocity_prober.global_position - floor_velocity_prober_position_prev
		floor_velocity_prober.global_position = floor_collision.get_position() if floor_collision != null else Vector3.ZERO

	if floor_snapping_enabled and floor_collision != null:
		state.set_transform(state.get_transform().translated_local(floor_collision.get_travel()))

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
