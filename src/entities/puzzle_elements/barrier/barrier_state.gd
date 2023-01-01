# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BarrierState
extends State

@onready var barrier: Barrier = owner


func _ready() -> void:
	assert(barrier != null, Errors.NULL_NODE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	barrier.collision_shape.disabled = !bool(get_index())
	if barrier.tween != null:
		barrier.tween.kill()
	barrier.tween = create_tween()
	barrier.tween.set_trans(Tween.TRANS_QUINT)
	barrier.tween.set_ease(Tween.EASE_OUT)
	barrier.tween.tween_method(barrier.set_alpha, float(!get_index()), float(get_index()), barrier.fade_duration)
