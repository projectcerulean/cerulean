# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends MeshInstance3D

@export var environment_resource: EnvironmentResource
@export var time_resource_gameplay: FloatResource
@export var player_transform_resource: TransformResource
@export var player_water_blob_shadow_enabled_resource: BoolResource

@onready var shader_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)
	assert(player_water_blob_shadow_enabled_resource != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	shader_material.set_shader_parameter(&"wave_time", time_resource_gameplay.value)
	shader_material.set_shader_parameter(&"wave_period", environment_resource.value.water_wave_period)
	shader_material.set_shader_parameter(&"wave_strength", environment_resource.value.water_wave_strength)
	shader_material.set_shader_parameter(&"wave_time_factor", environment_resource.value.water_wave_time_factor)
	shader_material.set_shader_parameter(&"beer_factor", environment_resource.value.water_beer_factor)
	shader_material.set_shader_parameter(&"water_color", environment_resource.value.water_color)
	shader_material.set_shader_parameter(&"water_color_highlight", environment_resource.value.water_color_highlight)
	shader_material.set_shader_parameter(&"foam_color", environment_resource.value.water_color_foam)
	shader_material.set_shader_parameter(&"blob_shadow_player_position", player_transform_resource.value.origin)
	shader_material.set_shader_parameter(&"player_blob_shadow_enabled", player_water_blob_shadow_enabled_resource.value)
