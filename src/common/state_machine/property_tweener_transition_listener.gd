# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PropertyTweenerTransitionListener
extends StateTransitionListener

@export var target_node: Node
@export var property: String
@export var value_min: float = 0.0
@export var value_max: float = 1.0
@export var tween_duration: float = 1.0

var tween: Tween


func _ready() -> void:
	super._ready()
	assert(target_node != null, Errors.NULL_NODE)
	assert(property != null and not property.is_empty(), Errors.INVALID_ARGUMENT)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target_node, property, value_max, tween_duration)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target_node, property, value_min, tween_duration)
