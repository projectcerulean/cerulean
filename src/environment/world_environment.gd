# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends WorldEnvironment

@export var _environment_resource: Resource

@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource


func _ready() -> void:
	assert(environment != null, Errors.NULL_RESOURCE)
	var cerulean_environment: CeruleanEnvironment = environment as CeruleanEnvironment
	assert(cerulean_environment != null, Errors.NULL_RESOURCE)
	environment_resource.value = cerulean_environment
