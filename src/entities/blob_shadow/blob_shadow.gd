# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var visual_change_min_distance: float = 0.0
@export var visual_change_max_distance: float = 25.0
@export var min_size: float = 0.4
@export var max_size: float = 4.0
@export var min_albedo_mix: float = 0.25
@export var max_albedo_mix: float = 0.85

@onready var decal_pivot: Node3D = get_node("DecalPivot") as Node3D
@onready var decal: Decal = get_node("DecalPivot/Decal") as Decal
@onready var raycast: RayCast3D = get_node("RayCast3D") as RayCast3D


func _ready() -> void:
	assert(decal_pivot != null, Errors.NULL_NODE)
	assert(decal != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		# Jump through some extra hoops here in order to prevent 'up vector and target direction aligned, look_at() failed' errors
		var up_direction: Vector3 = raycast.get_collision_normal().cross(Vector3.RIGHT).normalized()
		if not up_direction.is_normalized():
			up_direction = raycast.get_collision_normal().cross(Vector3.FORWARD).normalized()
		if not up_direction.is_normalized():
			up_direction = raycast.get_collision_normal().cross(Vector3.UP).normalized()
		decal_pivot.look_at_from_position(raycast.get_collision_point(), raycast.get_collision_point() + raycast.get_collision_normal(), up_direction)

		var raycast_distance: float = (raycast.get_collision_point() - raycast.global_position).length()
		decal.size = Vector3(0.0, decal.size.y, 0.0) + Vector3(1.0, 0.0, 1.0) * clampf(
			remap(
				raycast_distance,
				visual_change_min_distance,
				visual_change_max_distance,
				min_size,
				max_size
			),
			min_size,
			max_size,
		)
		decal.albedo_mix = clampf(
			remap(
				raycast_distance,
				visual_change_min_distance,
				visual_change_max_distance,
				max_albedo_mix,
				min_albedo_mix
			),
			min_albedo_mix,
			max_albedo_mix,
		)

		decal_pivot.visible = true
	else:
		decal_pivot.visible = false

	raycast.look_at(global_position + Vector3.DOWN, Vector3.RIGHT)
