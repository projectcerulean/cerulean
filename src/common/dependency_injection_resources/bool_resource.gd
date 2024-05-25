# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BoolResource
extends DependencyInjectionResource

const VALUE_DEFAULT: bool = false

var _value: bool = VALUE_DEFAULT


func get_value() -> bool:
	_validate_read()
	return _value


func set_value(caller: Node, value: bool) -> void:
	_validate_write(caller)
	_value = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_value = VALUE_DEFAULT
