# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener


func _ready() -> void:
	super._ready()


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
