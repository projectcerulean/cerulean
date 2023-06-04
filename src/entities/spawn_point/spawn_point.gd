# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Marker3D

@export var scene_transition_resource: Resource
@export var id: int = -1

var PlayerPreload: PackedScene = preload("res://src/entities/player/player.tscn")


func _ready() -> void:
	assert(scene_transition_resource != null, Errors.NULL_NODE)
	assert(id >= 0, Errors.INVALID_ARGUMENT)
	if scene_transition_resource.spawn_point_id == id:
		add_child(PlayerPreload.instantiate())
