# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node
## Keeps a reference to the persistent data resource to make sure it is never freed.

@export var persistent_data_resource: DictionaryResource


func _ready() -> void:
	assert(persistent_data_resource != null, Errors.NULL_RESOURCE)
