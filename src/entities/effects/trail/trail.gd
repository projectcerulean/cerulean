# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Trail
extends MeshInstance3D

@export var trail_width: Curve
@export var point_lifetime: float = 1.0

var curve_points_a: PackedVector3Array = []
var curve_points_b: PackedVector3Array = []
var curve_point_creation_times: PackedFloat64Array = []
var time: float = 0.0
var i_first_nondead_point: int = 0
var shall_queue_free: bool = false

@onready var immediate_mesh: ImmediateMesh = mesh as ImmediateMesh
@onready var material: StandardMaterial3D = material_override as StandardMaterial3D


func _ready() -> void:
	assert(immediate_mesh != null, Errors.NULL_RESOURCE)
	assert(trail_width != null, Errors.NULL_RESOURCE)
	assert(material != null, Errors.NULL_RESOURCE)
	assert(point_lifetime > 0.0, Errors.INVALID_ARGUMENT)


func _process(delta: float) -> void:
	assert(curve_points_b.size() == curve_points_a.size(), Errors.CONSISTENCY_ERROR)
	assert(curve_point_creation_times.size() == curve_points_a.size(), Errors.CONSISTENCY_ERROR)

	time += delta
	immediate_mesh.clear_surfaces()

	while i_first_nondead_point < curve_points_a.size() and time - curve_point_creation_times[i_first_nondead_point] > point_lifetime:
		i_first_nondead_point += 1

	if curve_points_a.size() - i_first_nondead_point > 1:
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i_point in range(i_first_nondead_point, curve_points_a.size()):
			var point_a: Vector3 = curve_points_a[i_point]
			var point_b: Vector3 = curve_points_b[i_point]
			var point_middle: Vector3 = (point_a + point_b) / 2.0

			var point_age: float = time - curve_point_creation_times[i_point]
			var width_factor: float = trail_width.interpolate(point_age / point_lifetime)
			immediate_mesh.surface_add_vertex(point_a * width_factor + point_middle * (1.0 - width_factor))
			immediate_mesh.surface_add_vertex(point_b * width_factor + point_middle * (1.0 - width_factor))
		immediate_mesh.surface_end()
	elif shall_queue_free:
		queue_free()


func add_segment(point_position_a: Vector3, point_position_b: Vector3) -> void:
	assert(not shall_queue_free, Errors.INVALID_CONTEXT)
	curve_points_a.append(point_position_a)
	curve_points_b.append(point_position_b)
	curve_point_creation_times.append(time)


func set_lifetime(lifetime: float):
	point_lifetime = lifetime


func set_color(color: Color):
	material.albedo_color = color


func finalize() -> void:
	shall_queue_free = true
