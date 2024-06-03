# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var environment_resource: EnvironmentResource
@export var time_resource_gameplay: FloatResource
@export var player_transform_resource: TransformResource
@export var camera_water_volume_height_resource: FloatResource
@export var water_mesh: PlaneMesh

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	assert(environment_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)
	assert(player_transform_resource != null, Errors.NULL_RESOURCE)
	assert(camera_water_volume_height_resource != null, Errors.NULL_RESOURCE)
	assert(water_mesh != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)

	assert(Math.is_odd(water_mesh.subdivide_width), Errors.NOT_IMPLEMENTED)
	assert(Math.is_odd(water_mesh.subdivide_depth), Errors.NOT_IMPLEMENTED)


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not is_instance_valid(camera):
		visible = false
		return

	visible = true

	var frustum: Array[Plane] = camera.get_frustum()
	var frustum_near: Plane = frustum[0]
	var frustum_sides: Array[Plane] = frustum.slice(2)
	var frustum_near_vertices: PackedVector3Array = []
	frustum_near_vertices.resize(len(frustum_sides))
	for i: int in range(len(frustum_sides)):
		var frustum_near_vertex: Vector3 = frustum_sides[i].intersect_3(frustum_sides[(i + 1) % frustum_sides.size()], frustum_near)
		frustum_near_vertices[i] = frustum_near_vertex

	var top_left_near_plane_vertex: Vector3 = frustum_near_vertices[0]
	var top_right_near_plane_vertex: Vector3 = frustum_near_vertices[1]
	var bottom_right_near_plane_vertex: Vector3 = frustum_near_vertices[2]
	var bottom_left_near_plane_vertex: Vector3 = frustum_near_vertices[3]

	shader_material.set_shader_parameter(&"color", environment_resource.value.water_screen_effect_color)
	shader_material.set_shader_parameter(&"wave_period", environment_resource.value.water_wave_period)
	shader_material.set_shader_parameter(&"wave_strength", environment_resource.value.water_wave_strength)
	shader_material.set_shader_parameter(&"wave_time_factor", environment_resource.value.water_wave_time_factor)
	shader_material.set_shader_parameter(&"foam_color", environment_resource.value.water_color)

	var wave_time: float = time_resource_gameplay.get_value() if time_resource_gameplay.is_owned() else 0.0
	shader_material.set_shader_parameter(&"wave_time", wave_time)

	var camera_water_volume_height: float = camera_water_volume_height_resource.get_value() if camera_water_volume_height_resource.is_owned() else -INF
	shader_material.set_shader_parameter(&"camera_water_volume_height", camera_water_volume_height)

	shader_material.set_shader_parameter(&"top_left_near_plane_vertex", top_left_near_plane_vertex)
	shader_material.set_shader_parameter(&"top_right_near_plane_vertex", top_right_near_plane_vertex)
	shader_material.set_shader_parameter(&"bottom_right_near_plane_vertex", bottom_right_near_plane_vertex)
	shader_material.set_shader_parameter(&"bottom_left_near_plane_vertex", bottom_left_near_plane_vertex)

	var water_mesh_face_size: Vector2 = water_mesh.size / (Vector2.ONE + Vector2(water_mesh.subdivide_width, water_mesh.subdivide_depth));
	shader_material.set_shader_parameter(&"water_mesh_face_size", water_mesh_face_size)
