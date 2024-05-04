# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name VectorUtils
extends Node


static func vec3_xz_to_vec2(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, vector3.z)


static func vec2_to_vec3_xz(vector2: Vector2) -> Vector3:
	return Vector3(vector2.x, 0.0, vector2.y)
