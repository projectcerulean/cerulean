# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends FogVolume

@export var environment_resource: EnvironmentResource
@export var time_resource_gameplay: FloatResource

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	if not environment_resource.value.volumetric_fog_enabled:
		push_warning("Volumetric fog not enabled")
		return

	shader_material.set_shader_parameter(&"color", environment_resource.value.water_color)
	shader_material.set_shader_parameter(&"density", environment_resource.value.underwater_fog_density)
	shader_material.set_shader_parameter(&"emission_factor", environment_resource.value.underwater_fog_emission_factor)
	shader_material.set_shader_parameter(&"wave_period", environment_resource.value.water_wave_period)
	shader_material.set_shader_parameter(&"wave_strength", environment_resource.value.water_wave_strength)
	shader_material.set_shader_parameter(&"wave_time_factor", environment_resource.value.water_wave_time_factor)

	var wave_time: float = time_resource_gameplay.get_value() if time_resource_gameplay.is_owned() else 0.0
	shader_material.set_shader_parameter(&"wave_time", wave_time)
