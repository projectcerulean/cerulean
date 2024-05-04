# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Math
extends Node


static func signed_sqrt(x: float) -> float:
	return signf(x) * sqrt(absf(x))


static func ellipse(radii: Vector2, theta: float) -> float:
	return radii.x * radii.y / sqrt((radii.y * cos(theta)) * (radii.y * cos(theta)) + (radii.x * sin(theta)) * (radii.x * sin(theta)))
