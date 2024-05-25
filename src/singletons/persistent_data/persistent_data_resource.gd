# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PersistentDataResource
extends Resource

var _data: Dictionary = {}


func store_int(caller: Node, key: StringName, value: int) -> void:
	_data[_get_full_key(caller, key)] = value


func get_int(caller: Node, key: StringName, default: int) -> int:
	var value: Variant = _data.get(_get_full_key(caller, key), default)
	if typeof(value) == TYPE_INT:
		return value
	else:
		return default


func _get_full_key(caller: Node, key: StringName) -> StringName:
	return StringName(String(caller.get_path())) + &":" + key
