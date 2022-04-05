# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SfxStateTransitionListener
extends StateTransitionListener

@export var _sfx_resource_enter: Resource
@export var _sfx_resource_exit: Resource

@onready var sfx_resource_enter: SfxResource = _sfx_resource_enter as SfxResource
@onready var sfx_resource_exit: SfxResource = _sfx_resource_exit as SfxResource

# If the node has a Node3D as parent, use its position for positional audio.
@onready var parent_3d: Node3D = get_parent() as Node3D


func _ready() -> void:
	super._ready()
	assert(sfx_resource_enter != null or sfx_resource_exit != null, Errors.INVALID_ARGUMENT)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if data.get(State.OLD_STATE, StringName()) == StringName() or sfx_resource_enter == null:
		return

	if parent_3d != null:
		Signals.emit_request_sfx_play(self, sfx_resource_enter, parent_3d.global_transform.origin)
	else:
		Signals.emit_request_sfx_play_non_diegetic(self, sfx_resource_enter)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if data.get(State.NEW_STATE, StringName()) == StringName() or sfx_resource_exit == null:
		return

	if parent_3d != null:
		Signals.emit_request_sfx_play(self, sfx_resource_exit, parent_3d.global_transform.origin)
	else:
		Signals.emit_request_sfx_play_non_diegetic(self, sfx_resource_exit)
