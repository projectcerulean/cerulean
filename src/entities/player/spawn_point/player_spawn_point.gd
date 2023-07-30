# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PlayerSpawnPoint
extends Marker3D

@export var scene_info_resource: SceneInfoResource
@export var id: int = -1

var PlayerPreload: PackedScene = preload("../player.tscn")


func _ready() -> void:
	assert(scene_info_resource != null, Errors.NULL_NODE)
	if scene_info_resource.spawn_point_id == id:
		add_child(PlayerPreload.instantiate())
