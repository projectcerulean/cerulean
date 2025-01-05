# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var min_speed: float = 12.0
@export var max_ground_distance: float = 5.0
@export var glide_ground_particles: GPUParticles3D
@export var glide_water_particles: GPUParticles3D
@export var player_state_resource: StateResource

@onready var player: RigidBody3D = owner as RigidBody3D
@onready var raycast: RayCast3D = get_node("RayCast3D") as RayCast3D
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector


func _ready() -> void:
	assert(player != null, Errors.NULL_NODE)
	assert(raycast != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)
	assert(glide_ground_particles != null, Errors.NULL_NODE)
	assert(glide_water_particles != null, Errors.NULL_NODE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)

	raycast.target_position = max_ground_distance * Vector3.DOWN


func _process(_delta: float) -> void:
	var water_surface_height: float = water_detector.get_water_surface_height()
	var water_surface_distance: float = global_position.y - water_surface_height
	var ground_height: float = raycast.get_collision_point().y if raycast.is_colliding() else -INF
	var ground_distance: float = global_position.y - ground_height

	var glide_ground_particles_emitting: bool = false
	var glide_water_particles_emitting: bool = false

	if (
		player_state_resource.get_current_state() in [PlayerStates.BOUNCE, PlayerStates.GLIDE]
		and VectorUtils.vec3_xz_to_vec2(player.linear_velocity).length() > min_speed
	):
		if (
			ground_distance > 0.0
			and ground_distance < max_ground_distance
			and ground_distance < water_surface_distance
		):
			glide_ground_particles_emitting = true
			glide_ground_particles.amount_ratio = remap(ground_distance, 0.0, max_ground_distance, 1.0, 0.0)
			glide_ground_particles.global_position = Vector3(
				global_position.x,
				ground_height,
				global_position.z,
			)
		elif (
			water_surface_distance > 0.0
			and water_surface_distance < max_ground_distance
			and water_surface_distance < ground_distance
		):
			glide_water_particles_emitting = true
			glide_water_particles.amount_ratio = remap(water_surface_distance, 0.0, max_ground_distance, 1.0, 0.0)
			glide_water_particles.global_position = Vector3(
				global_position.x,
				water_surface_height,
				global_position.z,
			)

	if not glide_ground_particles_emitting == glide_ground_particles.emitting:
		glide_ground_particles.emitting = glide_ground_particles_emitting
	if not glide_water_particles_emitting == glide_water_particles.emitting:
		glide_water_particles.emitting = glide_water_particles_emitting
