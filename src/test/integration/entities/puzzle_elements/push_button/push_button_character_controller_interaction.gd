# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PushButtonCharacterControllerInteraction
extends Scene

@onready var barrier: Barrier = get_node("Circuit/Barrier") as Barrier
@onready var character_controller: CharacterController = get_node("CharacterController") as CharacterController


func _ready() -> void:
	super._ready()
	assert(barrier != null, Errors.NULL_NODE)
	assert(character_controller != null, Errors.NULL_NODE)
