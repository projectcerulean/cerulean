# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends RigidBody3D

@export var buoyancy_force_factor: float = 5000.0
@export var buoyancy_central_factor: float = 0.9

@onready var water_detectors: Node3D = get_node("WaterDetectors") as Node3D


func _ready() -> void:
	assert(water_detectors != null, Errors.NULL_NODE)


func _physics_process(delta: float) -> void:
	for i in range(water_detectors.get_child_count()):
		var water_detector: WaterDetector = water_detectors.get_child(i) as WaterDetector
		if not is_inf(water_detector.get_water_surface_height()):
			var depth: float = water_detector.get_water_surface_height() - water_detector.global_position.y
			var force: float = buoyancy_force_factor * clampf(depth, 0.0, 1.0)
			var force_position: Vector3 = water_detector.global_position - global_position
			apply_central_force(buoyancy_central_factor * force * Vector3.UP)
			apply_force((1.0 - buoyancy_central_factor) * force * Vector3.UP, force_position)
