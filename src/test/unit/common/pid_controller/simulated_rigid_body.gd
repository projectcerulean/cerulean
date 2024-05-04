# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Simple, simulated, one-dimensional rigid body, for faster-than-realtime unit testing.
class_name SimulatedRigidBody
extends RefCounted

var _mass: float
var _position: float
var _linear_velocity: float
var _acceleration: float

var position: float:
	get:
		return _position


func _init(mass: float, initial_position: float) -> void:
	_mass = mass
	_position = initial_position


func simulate_physics_process(delta: float) -> void:
	_linear_velocity += _acceleration * delta
	_position += _linear_velocity * delta
	_acceleration = 0.0


func apply_central_force(force: float) -> void:
	_acceleration += force / _mass
