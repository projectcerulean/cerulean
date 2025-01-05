# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends GPUParticles3D


func _ready() -> void:
	emitting = true


func _process(_delta: float) -> void:
	# For one-shot particles, the 'emitting' property is automatically set to 'false' by godot at
	# end of the particle lifetime.
	if not emitting:
		queue_free()
