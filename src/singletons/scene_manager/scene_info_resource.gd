# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SceneInfoResource
extends DependencyInjectionResource

const SCENE_PATH_DEFAULT: String = String()
const SPAWN_POINT_ID_DEFAULT: int = -1

var _scene_path: NodePath = SCENE_PATH_DEFAULT
var _spawn_point_id: int = SPAWN_POINT_ID_DEFAULT

func get_scene_path() -> String:
	_validate_read("scene_path")
	return _scene_path


func set_scene_path(caller: Node, value: String) -> void:
	_validate_write(caller, "scene_path")
	_scene_path = value


func get_spawn_point_id() -> int:
	_validate_read("spawn_point_id")
	return _spawn_point_id


func set_spawn_point_id(caller: Node, value: int) -> void:
	_validate_write(caller, "spawn_point_id")
	_spawn_point_id = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_scene_path = SCENE_PATH_DEFAULT
	_spawn_point_id = SPAWN_POINT_ID_DEFAULT
