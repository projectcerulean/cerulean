# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Translate3DTransitionListener
extends StateTransitionListener

@export var target_node: Node3D
@export var position_target: Node3D
@export var tween_duration: float = 1.0

var tween: Tween


func _ready() -> void:
	super._ready()
	assert(target_node != null, Errors.NULL_NODE)
	assert(position_target != null, Errors.NULL_NODE)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if data.get(State.OLD_STATE, StringName()) == StringName():
		target_node.global_position = position_target.global_position
	else:
		if tween != null:
			tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(target_node, "global_position", position_target.global_position, tween_duration)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if tween != null:
		tween.kill()
