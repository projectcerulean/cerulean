# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name DialogueState
extends State

# Reference to the dialogue manager so that it can be manipulated inside the states
@onready var dialogue_manager: DialogueManager = owner


func _ready() -> void:
	assert(dialogue_manager != null, Errors.NULL_NODE)
