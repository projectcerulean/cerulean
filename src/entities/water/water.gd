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
	shader_material.set_shader_parameter(&"wave_period", environment_resource.value.water_wave_period)
	shader_material.set_shader_parameter(&"wave_strength", environment_resource.value.water_wave_strength)
	shader_material.set_shader_parameter(&"wave_time_factor", environment_resource.value.water_wave_time_factor)
	shader_material.set_shader_parameter(&"beer_factor", environment_resource.value.water_beer_factor)
	shader_material.set_shader_parameter(&"water_color", environment_resource.value.water_color)
	shader_material.set_shader_parameter(&"water_color_highlight", environment_resource.value.water_color_highlight)
	shader_material.set_shader_parameter(&"foam_color", environment_resource.value.water_color_foam)

	var wave_time: float = time_resource_gameplay.get_value() if time_resource_gameplay.is_owned() else 0.0
	shader_material.set_shader_parameter(&"wave_time", wave_time)

	var player_position: Vector3 = player_transform_resource.get_value().origin if player_transform_resource.is_owned() else Vector3.ZERO
	shader_material.set_shader_parameter(&"blob_shadow_player_position", player_position)

	var player_blob_shadow_enabled: bool = player_water_blob_shadow_enabled_resource.get_value() if player_water_blob_shadow_enabled_resource.is_owned() else false
	shader_material.set_shader_parameter(&"player_blob_shadow_enabled", player_blob_shadow_enabled)
