# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var angular_velocity: Vector3 = Vector3(0.5, 0.25, 0.125)

@export var angular_velocity_factor: float = 1.0


func _process(delta: float) -> void:
	rotate_x(angular_velocity.x * angular_velocity_factor * delta)
	rotate_y(angular_velocity.y * angular_velocity_factor * delta)
	rotate_z(angular_velocity.z * angular_velocity_factor * delta)
