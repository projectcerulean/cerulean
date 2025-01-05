# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var camera_shake_resource: CameraShakeSustainedResource


func _ready() -> void:
	super._ready()
	assert(camera_shake_resource != null, Errors.NULL_RESOURCE)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if data.get(State.OLD_STATE, StringName()) != StringName():
		Signals.emit_request_camera_shake_sustained(self, camera_shake_resource)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	Signals.emit_request_camera_shake_sustained_stop(self)
