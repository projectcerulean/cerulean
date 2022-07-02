# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends AnimatableBody3D

var transform_lerp_weight: float = 10.0

@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector


func _ready() -> void:
	assert(water_detector != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	global_transform.origin.y = Lerp.delta_lerp(global_transform.origin.y, water_detector.get_water_surface_height(), transform_lerp_weight, delta)
