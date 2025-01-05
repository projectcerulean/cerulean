# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name WaterDetector
extends Area3D

@export var environment_resource: EnvironmentResource
@export var time_resource_gameplay: FloatResource

var water_bodies: Array[Area3D]


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)

	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)


func _on_scene_changed(_sender: NodePath) -> void:
	water_bodies.clear()


func _on_area_entered(area: Area3D) -> void:
	assert(str(area.owner.name).begins_with("Water"), Errors.CONSISTENCY_ERROR)
	water_bodies.append(area)


func _on_area_exited(area: Area3D) -> void:
	if area in water_bodies:
		water_bodies.erase(area)


func is_in_water() -> bool:
	return global_position.y < get_water_surface_height()


func get_water_volume_height() -> float:
	var height: float = -INF
	for area: Area3D in water_bodies:
		height = max(
			height,
			area.global_position.y,
		)
	return height


func get_water_surface_height() -> float:
	var environment: CeruleanEnvironment = environment_resource.value
	var time: float = time_resource_gameplay.get_value() if time_resource_gameplay.is_owned() else 0.0

	var height: float = -INF
	for area: Area3D in water_bodies:
		height = max(
			height,
			area.global_position.y + (
				environment.water_wave_strength.x * sin(
					global_position.x * TAU / environment.water_wave_period.x
					+ time * environment.water_wave_time_factor.x
				)
				+ environment.water_wave_strength.y * sin(
					global_position.z * TAU / environment.water_wave_period.y
					+ time * environment.water_wave_time_factor.y
				)
			)
		)
	return height
