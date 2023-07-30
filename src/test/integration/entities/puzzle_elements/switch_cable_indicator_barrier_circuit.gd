# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SwitchCableIndicatorBarrierCircuit
extends Node3D

@onready var switch: Switch = get_node("Circuit/Switch") as Switch
@onready var cable_1: Cable = get_node("Circuit/Cable1") as Cable
@onready var cable_2: Cable = get_node("Circuit/Cable2") as Cable
@onready var indicator: Indicator = get_node("Circuit/Indicator") as Indicator
@onready var barrier: Barrier = get_node("Circuit/Barrier") as Barrier


func _ready() -> void:
	assert(switch != null, Errors.NULL_NODE)
	assert(cable_1 != null, Errors.NULL_NODE)
	assert(cable_2 != null, Errors.NULL_NODE)
	assert(indicator != null, Errors.NULL_NODE)
	assert(barrier != null, Errors.NULL_NODE)
