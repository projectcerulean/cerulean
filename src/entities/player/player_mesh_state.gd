# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerMeshState
extends State

const YAW_DIRECTION: StringName = &"YAW_DIRECTION"
const YAW_DIRECTION_TARGET: StringName = &"YAW_DIRECTION_TARGET"

@export var _mesh_root: NodePath
@export var _player_input_vector_resource: Resource

@onready var mesh_root: Node3D = get_node(_mesh_root) as Node3D
@onready var player: CharacterBody3D = owner as CharacterBody3D
@onready var player_input_vector_resource: Vector3Resource = _player_input_vector_resource as Vector3Resource


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
