# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Provides a visual indication that the player has performed a double-jump, or similar action.
class_name WindCircleEffect
extends Node3D

@export var environment_resource: EnvironmentResource
@export var player_mesh_height: float = 1.25
@export var time_max: float = 0.2

@export var inner_radius: Curve
@export var outer_radius: Curve

var _time: float = 0.0

# Use separate meshes since multi-pass shaders do not seem to work properly (ShaderMaterial.get_next_pass() always returns null?).
@onready var _shader_material_1: ShaderMaterial = (get_node("Mesh1") as MeshInstance3D).get_surface_override_material(0) as ShaderMaterial
@onready var _shader_material_2: ShaderMaterial = (get_node("Mesh2") as MeshInstance3D).get_surface_override_material(0) as ShaderMaterial
@onready var _shader_material_3: ShaderMaterial = (get_node("Mesh3") as MeshInstance3D).get_surface_override_material(0) as ShaderMaterial
@onready var _shader_materials: Array[ShaderMaterial] = [
	_shader_material_1,
	_shader_material_2,
	_shader_material_3,
]


func _ready() -> void:
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(inner_radius != null, Errors.NULL_RESOURCE)
	assert(outer_radius != null, Errors.NULL_RESOURCE)
	assert(_shader_material_1 != null, Errors.NULL_RESOURCE)
	assert(_shader_material_2 != null, Errors.NULL_RESOURCE)
	assert(_shader_material_3 != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	_time = _time + delta
	if _time > time_max:
		visible = false
		set_process(false)
		for shader_material: ShaderMaterial in _shader_materials:
			shader_material.set_shader_parameter(&"inner_radius", 0.0)
			shader_material.set_shader_parameter(&"outer_radius", 0.0)
	else:
		var progress: float = _time / time_max
		for shader_material: ShaderMaterial in _shader_materials:
			shader_material.set_shader_parameter(&"inner_radius", inner_radius.sample(progress))
			shader_material.set_shader_parameter(&"outer_radius", outer_radius.sample(progress))


func trigger() -> void:
	var albedo_color: Color = environment_resource.value.wind_trail_color
	_shader_material_3.set_shader_parameter(&"albedo_color", albedo_color)
	_time = 0.0
	visible = true
	set_process(true)
