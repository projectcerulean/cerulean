# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends WorldEnvironment

@export var environment_resource: EnvironmentResource


func _ready() -> void:
	if is_instance_valid(environment):
		assert(environment_resource != null, Errors.NULL_RESOURCE)
		var cerulean_environment: CeruleanEnvironment = environment as CeruleanEnvironment
		assert(cerulean_environment != null, Errors.NULL_RESOURCE)
		environment_resource.value = cerulean_environment
