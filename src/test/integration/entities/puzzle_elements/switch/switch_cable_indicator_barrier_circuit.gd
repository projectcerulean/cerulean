# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SwitchCableIndicatorBarrierCircuit
extends Scene

@onready var interaction_manager: InteractionManager = get_node("InteractionManager") as InteractionManager
@onready var barrier: Barrier = get_node("Circuit/Barrier") as Barrier


func _ready() -> void:
	super._ready()
	assert(interaction_manager != null, Errors.NULL_NODE)
	assert(barrier != null, Errors.NULL_NODE)
