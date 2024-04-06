# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Provides a visual indication that the player has performed a double-jump.
extends MeshInstance3D

@export var environment_resource: EnvironmentResource
@export var player_state_resource: StateResource
@export var player_transform_resource: TransformResource
@export var player_mesh_height: float = 1.25
@export var time_max: float = 0.2

var time: float = 0.0

@export var inner_radius: Curve
@export var outer_radius: Curve

@onready var shader_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)

	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)
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


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if sender == player_state_resource.state_machine and state == PlayerStates.DOUBLE_JUMP:
		global_transform.origin = player_transform_resource.value.origin + Vector3.DOWN * player_mesh_height / 2.0
		var albedo_color: Color = environment_resource.value.wind_trail_color
		shader_material.set_shader_parameter(&"albedo_color", albedo_color)
		visible = true
		time = 0.0
