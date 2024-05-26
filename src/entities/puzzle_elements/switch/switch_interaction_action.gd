# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SwitchInteractionAction
extends InteractionAction

@export var switch: NodePath


func check(caller: Node3D) -> void:
	var switch: Switch = caller.get_node(switch) as Switch
	assert(switch != null, Errors.NULL_NODE)


func interact(caller: Node3D) -> void:
	super.interact(caller)
	var switch: Switch = caller.get_node(switch) as Switch
	switch.flip()
