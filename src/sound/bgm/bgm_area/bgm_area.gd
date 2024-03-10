# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Area3D

@export var bgm: StringName


func _ready() -> void:
	assert(bgm == null or bgm == StringName() or bgm in BgmIndex.BGM_INDEX, Errors.INVALID_ARGUMENT)


func _on_body_entered(_body: Node3D) -> void:
	var collision_shape: CollisionShape3D = TreeUtils.get_collision_shape_for_area(self)
	var area_volume: float = ShapeUtils.calculate_shape_volume(collision_shape.shape)
	var bgm_priority: float = 1.0 / area_volume
	Signals.emit_bgm_area_entered(self, bgm, bgm_priority)


func _on_body_exited(_body: Node3D) -> void:
	Signals.emit_bgm_area_exited(self)
