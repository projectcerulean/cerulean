# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name InteractionManagerTestScene
extends Scene

@onready var interaction_manager: InteractionManager = get_node("InteractionManager") as InteractionManager
@onready var interactable_1: Interactable = get_node("Interactable1") as Interactable
@onready var interactable_2: Interactable = get_node("Interactable2") as Interactable
@onready var state_machine_1: StateMachine = get_node("StateMachine1") as StateMachine
@onready var state_machine_2: StateMachine = get_node("StateMachine2") as StateMachine
@onready var end_position: Marker3D = get_node("EndPosition") as Marker3D


func _ready() -> void:
	super._ready()
	assert(interaction_manager != null, Errors.NULL_NODE)
	assert(interactable_1 != null, Errors.NULL_NODE)
	assert(interactable_2 != null, Errors.NULL_NODE)
	assert(state_machine_1 != null, Errors.NULL_NODE)
	assert(state_machine_2 != null, Errors.NULL_NODE)
	assert(end_position != null, Errors.NULL_NODE)
