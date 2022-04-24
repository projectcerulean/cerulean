# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var _trail_position_a: NodePath
@export var _trail_position_b: NodePath
@export var point_lifetime: float = 0.5

var trail: Trail = null

@onready var trail_position_a: Node3D = get_node(_trail_position_a) as Node3D
@onready var trail_position_b: Node3D = get_node(_trail_position_b) as Node3D


func _ready() -> void:
	super._ready()
	assert(trail_position_a != null, Errors.NULL_NODE)
	assert(trail_position_b != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	if is_in_target_state and trail != null:
		trail.add_segment(trail_position_a.global_transform.origin, trail_position_b.global_transform.origin)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	trail = preload("res://src/entities/effects/trail/trail.tscn").instantiate()
	add_child(trail)
	trail.set_lifetime(point_lifetime)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	trail.finalize()
	trail = null
