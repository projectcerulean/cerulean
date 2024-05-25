# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

const OneShotWaterSplashParticlesPreload: PackedScene = preload("res://src/entities/player/particles/one_shot_water_splash_particles.tscn")

@export var player_min_speed: float = 7.0
@export var player_state_resource: StateResource
@export var particle_y_speed: float = 8.0
@export var glide_max_angle_from_vertical: float = PI / 4.0

@onready var player: RigidBody3D = owner as RigidBody3D
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)
	Signals.state_exited.connect(_on_state_exited)
	assert(player != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)
	assert(player_state_resource != null, Errors.NULL_RESOURCE)


func emit_particles() -> void:
	var water_surface_height: float = water_detector.get_water_surface_height()

	var water_splash_particles: GPUParticles3D = OneShotWaterSplashParticlesPreload.instantiate() as GPUParticles3D
	var process_material: ParticleProcessMaterial = water_splash_particles.process_material as ParticleProcessMaterial
	assert(process_material != null, Errors.NULL_RESOURCE)

	var particle_velocity: Vector3 = Vector3(player.linear_velocity.x, particle_y_speed, player.linear_velocity.z)
	process_material.direction = particle_velocity.normalized()
	process_material.initial_velocity_min = particle_velocity.length()
	process_material.initial_velocity_max = particle_velocity.length()

	add_child(water_splash_particles)
	water_splash_particles.global_position = Vector3(
		global_position.x,
		water_surface_height,
		global_position.z,
	)


func _on_state_entered(sender: NodePath, state: StringName, data: Dictionary) -> void:
	if (
		sender == player_state_resource.get_state_machine()
		and player.linear_velocity.length() > player_min_speed
		and state == PlayerStates.SWIM
		and (
			data.get(State.OLD_STATE) == PlayerStates.FALL
			or (
				data.get(State.OLD_STATE) == PlayerStates.GLIDE
				and player.linear_velocity.angle_to(Vector3.DOWN) < glide_max_angle_from_vertical
			)
		)
	):
		emit_particles()


func _on_state_exited(sender: NodePath, state: StringName, data: Dictionary) -> void:
	if (
		sender == player_state_resource.get_state_machine()
		and state == PlayerStates.SWIM
		and data.get(State.NEW_STATE) == PlayerStates.JUMP
	):
		emit_particles()
