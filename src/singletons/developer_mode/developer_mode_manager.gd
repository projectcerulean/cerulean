# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node
## Activates various 'cheats' and other handy developer features if the environment variable
## CERULEAN_DEVELOPER_MODE is set. The developer mode can only be activated when running a Godot
## debug build.

@export var developer_mode_resource: BoolResource


func _enter_tree() -> void:
	assert(developer_mode_resource != null, Errors.NULL_RESOURCE)
	developer_mode_resource.claim_ownership(self)

	var is_developer_mode_enabled: bool = false
	var environment_variable: String = "%s_DEVELOPER_MODE" % Version.SHORT_NAME.to_upper()
	if OS.is_debug_build() and OS.has_environment(environment_variable):
		push_warning("%s developer mode is active (%s is set)" % [Version.NAME, environment_variable])
		is_developer_mode_enabled = true
	developer_mode_resource.set_value(self, is_developer_mode_enabled)


func _exit_tree() -> void:
	developer_mode_resource.release_ownership(self)
