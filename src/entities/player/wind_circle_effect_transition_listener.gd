# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var target_transform: Node3D

@onready var wind_circle_effect: WindCircleEffect = get_node("WindCircleEffect") as WindCircleEffect


func _ready() -> void:
	super._ready()
	assert(target_transform != null, Errors.NULL_NODE)
	assert(wind_circle_effect != null, Errors.NULL_NODE)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	wind_circle_effect.global_transform = target_transform.global_transform
	wind_circle_effect.trigger()
