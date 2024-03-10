# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SwitchCableIndicatorBarrierCircuit
extends Scene

@onready var switch_interaction_action: SwitchInteractionAction = get_node("Circuit/Switch/Joint/Crystal/Interaction/Action") as SwitchInteractionAction
@onready var barrier: Barrier = get_node("Circuit/Barrier") as Barrier


func _ready() -> void:
	super._ready()
	assert(switch_interaction_action != null, Errors.NULL_NODE)
	assert(barrier != null, Errors.NULL_NODE)
