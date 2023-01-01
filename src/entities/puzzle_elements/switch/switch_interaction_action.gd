# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SwitchInteractionAction
extends InteractionAction

@onready var switch: Switch = owner


func _ready() -> void:
	assert(switch != null, Errors.NULL_NODE)


func interact() -> void:
	super.interact()
	switch.flip()
