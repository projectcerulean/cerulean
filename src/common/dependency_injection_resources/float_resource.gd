# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name FloatResource
extends DependencyInjectionResource

const VALUE_DEFAULT: float = 0.0

var _value: float = VALUE_DEFAULT


func get_value() -> float:
	_validate_read()
	return _value


func set_value(caller: Node, value: float) -> void:
	_validate_write(caller)
	_value = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_value = VALUE_DEFAULT
