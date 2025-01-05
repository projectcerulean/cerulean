# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	assert(shader_material != null, Errors.NULL_RESOURCE)
	shader_material.set_shader_parameter(&"color", color)
