# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var thumbstick_resource_left: Vector2Resource
@export var thumbstick_resource_right: Vector2Resource


func _ready() -> void:
	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	assert(thumbstick_resource_right != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	# The thumbstick resource values are reset to zero before each input polling.
	# The largest input (gamepad or mouse+keyboard) is the one that will actually be used.
	thumbstick_resource_left.value = Vector2.ZERO
	thumbstick_resource_right.value = Vector2.ZERO
