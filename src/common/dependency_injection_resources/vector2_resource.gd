# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Vector2Resource
extends DependencyInjectionResource

const VALUE_DEFAULT: Vector2 = Vector2()

var _value: Vector2 = VALUE_DEFAULT


func get_value() -> Vector2:
	_validate_read()
	return _value


func set_value(caller: Node, value: Vector2) -> void:
	_validate_write(caller)
	_value = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_value = VALUE_DEFAULT
