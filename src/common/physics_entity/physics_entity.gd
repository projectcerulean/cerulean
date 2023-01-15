# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PhysicsEntity
extends RigidBody3D

var linear_velocity_prev: Vector3 = Vector3.ZERO
var pending_impulse_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_velocities: PackedVector3Array = PackedVector3Array()
var pending_bounce_elasticities: PackedFloat64Array = PackedFloat64Array()


func _ready() -> void:
	Signals.request_body_bounce.connect(_on_request_body_bounce)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for i in range(len(pending_impulse_velocities)):
		var impulse_velocity: Vector3 = pending_impulse_velocities[i]
		var impulse_normal: Vector3 = impulse_velocity.normalized()
		var planar_velocity: Vector3 = Plane(impulse_normal).project(state.linear_velocity)
		var projected_velocity: Vector3 = state.linear_velocity.project(impulse_normal)
		if projected_velocity.length() < impulse_velocity.length() or projected_velocity.dot(impulse_velocity) < 0.0:
			state.linear_velocity = impulse_velocity + planar_velocity
	pending_impulse_velocities.clear()

	for i in range(len(pending_bounce_velocities)):
		var bounce_velocity: Vector3 = pending_bounce_velocities[i]
		var bounce_normal: Vector3 = bounce_velocity.normalized()
		assert(bounce_normal, Errors.CONSISTENCY_ERROR)

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

	linear_velocity_prev = state.linear_velocity


func enqueue_impulse(target_velocity: Vector3):
	pending_impulse_velocities.append(target_velocity)


func enqueue_bounce(bounce_velocity: Vector3, elasticy: float):
	pending_bounce_velocities.append(bounce_velocity)
	pending_bounce_elasticities.append(elasticy)


func _on_request_body_bounce(_sender: Node, body: Node3D, target_velocity: Vector3, elasticy: float) -> void:
	if body == self:
		enqueue_bounce(target_velocity, elasticy)
