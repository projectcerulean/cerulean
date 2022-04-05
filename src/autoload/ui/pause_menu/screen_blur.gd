# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var lerp_weight: float = 36.12
@export var _game_state_resource: Resource

@onready var shader_material: ShaderMaterial = material as ShaderMaterial
@onready var blur_strength_max: float = shader_material.get_shader_param("blur_strength")
@onready var game_state_resource: StateResource = _game_state_resource as StateResource

var blur_strength: float = 0.0


func _ready() -> void:
	assert(game_state_resource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	var blur_strength_target: float = 0.0
	if game_state_resource.current_state == GameStates.PAUSE:
		blur_strength_target = blur_strength_max
	blur_strength = Lerp.delta_lerp(blur_strength, blur_strength_target, lerp_weight, delta)
	shader_material.set_shader_param("blur_strength", blur_strength)
