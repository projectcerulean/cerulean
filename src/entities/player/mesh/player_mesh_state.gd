# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerMeshState
extends State

const ROLL_ANGLE: StringName = &"ROLL_ANGLE"
const YAW_DIRECTION: StringName = &"YAW_DIRECTION"
const YAW_DIRECTION_TARGET: StringName = &"YAW_DIRECTION_TARGET"

@export var mesh_root: Node3D
@export var _player_input_vector_resource: Resource

@onready var player: RigidBody3D = owner as RigidBody3D
@onready var player_input_vector_resource: Vector2Resource = _player_input_vector_resource as Vector2Resource


func _ready() -> void:
	assert(mesh_root != null, Errors.NULL_NODE)
	assert(player != null, Errors.NULL_NODE)
	assert(player_input_vector_resource != null, Errors.NULL_RESOURCE)


func enter(data: Dictionary) -> void:
	super.enter(data)
	mesh_root.show()


func exit(data: Dictionary) -> void:
	super.exit(data)
	mesh_root.hide()
