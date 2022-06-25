# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerState extends State

@export var water_state_enter_offset: float = 0.1

# Reference to the player object so that it can be manipulated inside the states
var player: Player = null


func _ready() -> void:
	player = owner as Player
	assert(player != null, Errors.NULL_NODE)
