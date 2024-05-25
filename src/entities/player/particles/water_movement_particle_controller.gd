# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var min_speed: float = 5.0
@export var max_speed: float = 12.0
@export var swim_min_speed: float = 8.0
@export var swim_max_speed: float = 12.0
@export var player_mesh_height: float = 1.25
@export var splash_particle_y_speed: float = 8.0
@export var water_movement_trail_particles: GPUParticles3D
@export var water_movement_splash_particles: GPUParticles3D
@export var player_state_resource: StateResource

@onready var player: RigidBody3D = owner as RigidBody3D
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector


func _ready() -> void:
	assert(player != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)
	assert(water_movement_trail_particles != null, Errors.NULL_NODE)
	assert(water_movement_splash_particles != null, Errors.NULL_NODE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	var water_surface_height: float = water_detector.get_water_surface_height()
	var water_surface_distance: float = global_position.y - water_surface_height

	var emitting: bool = false

	if (
		water_surface_distance > -player_mesh_height / 2.0
		and water_surface_distance < player_mesh_height / 2.0
	):
		emitting = true
		var amount_ratio: float = NAN
		if player_state_resource.get_current_state() in [PlayerStates.SWIM, PlayerStates.DIVE]:
			amount_ratio = clampf(
				remap(
					VectorUtils.vec3_xz_to_vec2(player.linear_velocity).length(),
					swim_min_speed,
					swim_max_speed,
					0.0,
					1.0,
				),
				0.0,
				1.0,
			)
		else:
			amount_ratio = clampf(
				remap(
					VectorUtils.vec3_xz_to_vec2(player.linear_velocity).length(),
					min_speed,
					max_speed,
					0.0,
					1.0,
				),
				0.0,
				1.0,
			)
		water_movement_trail_particles.amount_ratio = amount_ratio
		water_movement_splash_particles.amount_ratio = amount_ratio
		water_movement_trail_particles.global_position = Vector3(
			global_position.x,
			water_surface_height,
			global_position.z,
		)
		water_movement_splash_particles.global_position = Vector3(
			global_position.x,
			water_surface_height,
			global_position.z,
		)

		var process_material: ParticleProcessMaterial = water_movement_splash_particles.process_material as ParticleProcessMaterial
		assert(process_material != null, Errors.NULL_RESOURCE)

		var particle_velocity: Vector3 = Vector3(player.linear_velocity.x, splash_particle_y_speed, player.linear_velocity.z)
		process_material.direction = particle_velocity.normalized()
		process_material.initial_velocity_min = particle_velocity.length()
		process_material.initial_velocity_max = particle_velocity.length()

	if not emitting == water_movement_trail_particles.emitting:
		water_movement_trail_particles.emitting = emitting
	if not emitting == water_movement_splash_particles.emitting:
		water_movement_splash_particles.emitting = emitting
