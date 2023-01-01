# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name ScreenShakeTransitionListener
extends StateTransitionListener

@export var total_duration: float = 1.0
@export var shake_frequency: float = 30.0
@export var amplitude: float = 0.1


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if data.get(State.OLD_STATE, StringName()) != StringName():
		Signals.emit_request_screen_shake(self, total_duration, shake_frequency, amplitude)
