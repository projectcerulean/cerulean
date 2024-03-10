# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var color_disabled: Color = Color(1.0, 0.27, 0.0)
@export var color_enabled: Color = Color(0.0, 0.71, 1.0)

var activation: float:
	get:
		var value: float = clampf(activation, 0.0, 1.0)
		if is_nan(value):
			return 0.0
		else:
			return value
	set (value):
		assert(not is_nan(value) and not is_inf(value), Errors.INVALID_ARGUMENT)
		activation = clampf(value, 0.0, 1.0)
		for node in get_children():
			if node is MeshInstance3D:
				var mesh_instance: MeshInstance3D = node as MeshInstance3D
				var material: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial
				material.set_shader_parameter(&"albedo", color_disabled.lerp(color_enabled, activation))
			elif node is Light3D:
				var light: Light3D = node as Light3D
				light.light_color = color_disabled.lerp(color_enabled, activation)


func _ready() -> void:
	activation = 0.0
