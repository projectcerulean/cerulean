# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var visual_change_min_distance: float = 0.0
@export var visual_change_max_distance: float = 25.0
@export var min_extents: float = 0.2
@export var max_extents: float = 2.0
@export var min_albedo_mix: float = 0.25
@export var max_albedo_mix: float = 0.85

@onready var decal_pivot: Node3D = get_node("DecalPivot") as Node3D
@onready var decal: Decal = get_node("DecalPivot/Decal") as Decal
@onready var raycast: RayCast3D = get_node("RayCast3D") as RayCast3D
@onready var decal_extents_default: Vector3 = decal.extents


func _ready() -> void:
	assert(decal_pivot != null, Errors.NULL_NODE)
	assert(decal != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	if raycast.is_colliding():
		var up_direction: Vector3 = Vector3.RIGHT if raycast.get_collision_normal().is_equal_approx(Vector3.UP) else Vector3.UP
		decal_pivot.look_at_from_position(raycast.get_collision_point(), raycast.get_collision_point() + raycast.get_collision_normal(), up_direction)

		var raycast_distance: float = (raycast.get_collision_point() - raycast.global_position).length()
		decal.extents = Vector3(0.0, decal.extents.y, 0.0) + Vector3(1.0, 0.0, 1.0) * clamp(
			range_lerp(
				raycast_distance,
				visual_change_min_distance,
				visual_change_max_distance,
				min_extents,
				max_extents
			),
			min_extents,
			max_extents,
		)
		decal.albedo_mix = clamp(
			range_lerp(
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
