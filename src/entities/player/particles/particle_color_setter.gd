# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name ParticleColorSetter
extends Node

@export var particle_material: StandardMaterial3D
@export var environment_resource: EnvironmentResource


func _ready() -> void:
	assert(particle_material != null, Errors.NULL_RESOURCE)
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	_process(get_process_delta_time())


func _process(_delta: float) -> void:
	particle_material.albedo_color = get_color()


# Override this
func get_color() -> Color:
	return Color()
