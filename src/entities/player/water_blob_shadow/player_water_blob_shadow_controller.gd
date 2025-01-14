# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var player_water_blob_shadow_enabled_resource: BoolResource

@onready var raycast: RayCast3D = get_node("RayCast3D") as RayCast3D
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector


func _enter_tree() -> void:
	assert(player_water_blob_shadow_enabled_resource != null, Errors.NULL_RESOURCE)
	player_water_blob_shadow_enabled_resource.claim_ownership(self)


func _exit_tree() -> void:
	player_water_blob_shadow_enabled_resource.release_ownership(self)


func _ready() -> void:
	assert(raycast != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	var water_surface_height: float = water_detector.get_water_surface_height()
	var water_surface_distance: float = global_position.y - water_surface_height
	var ground_height: float = raycast.get_collision_point().y if raycast.is_colliding() else -INF
	var ground_distance: float = global_position.y - ground_height

	player_water_blob_shadow_enabled_resource.set_value(self,
		water_surface_distance > 0.0
		and water_surface_distance < ground_distance
	)
