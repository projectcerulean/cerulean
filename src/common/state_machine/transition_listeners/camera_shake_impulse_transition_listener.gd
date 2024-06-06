# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var shake_trauma_enter: float = 0.0
@export var shake_trauma_exit: float = 0.0


func _ready() -> void:
	super._ready()
	assert(shake_trauma_enter >= 0.0 and shake_trauma_enter <= 1.0, Errors.INVALID_ARGUMENT)
	assert(shake_trauma_exit >= 0.0 and shake_trauma_exit <= 1.0, Errors.INVALID_ARGUMENT)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if data.get(State.OLD_STATE, StringName()) != StringName():
		if not is_zero_approx(shake_trauma_enter):
			Signals.emit_request_camera_shake_impulse(self, shake_trauma_enter)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if not is_zero_approx(shake_trauma_exit):
		Signals.emit_request_camera_shake_impulse(self, shake_trauma_exit)
