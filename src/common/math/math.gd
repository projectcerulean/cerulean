# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Math
extends Node


static func is_even(number: int) -> bool:
	return number % 2 == 0


static func is_odd(number: int) -> bool:
	return not is_even(number)


static func signed_sqrt(x: float) -> float:
	return signf(x) * sqrt(absf(x))


static func ellipse(radii: Vector2, theta: float) -> float:
	return radii.x * radii.y / sqrt((radii.y * cos(theta)) * (radii.y * cos(theta)) + (radii.x * sin(theta)) * (radii.x * sin(theta)))
