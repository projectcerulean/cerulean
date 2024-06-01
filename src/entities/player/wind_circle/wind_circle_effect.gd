# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Provides a visual indication that the player has performed a double-jump, or similar action.
class_name WindCircleEffect
extends MeshInstance3D

@export var environment_resource: EnvironmentResource
@export var player_mesh_height: float = 1.25
@export var time_max: float = 0.2

@export var inner_radius: Curve
@export var outer_radius: Curve

var time: float = 0.0

@onready var shader_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(inner_radius != null, Errors.NULL_RESOURCE)
	assert(outer_radius != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	time = time + delta
	if time > time_max:
		visible = false
		shader_material.set_shader_parameter(&"inner_radius", 0.0)
		shader_material.set_shader_parameter(&"outer_radius", 0.0)
	else:
		var progress: float = time / time_max
		shader_material.set_shader_parameter(&"inner_radius", inner_radius.sample(progress))
		shader_material.set_shader_parameter(&"outer_radius", outer_radius.sample(progress))


func trigger() -> void:
	var albedo_color: Color = environment_resource.value.wind_trail_color
	shader_material.set_shader_parameter(&"albedo_color", albedo_color)
	visible = true
	time = 0.0
