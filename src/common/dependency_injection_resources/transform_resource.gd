# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TransformResource
extends DependencyInjectionResource

const VALUE_DEFAULT: Transform3D = Transform3D()

var _value: Transform3D = VALUE_DEFAULT


func get_value() -> Transform3D:
	_validate_read()
	return _value


func set_value(caller: Node, value: Transform3D) -> void:
	_validate_write(caller)
	_value = value


func release_ownership(caller: Node) -> void:
	super.release_ownership(caller)
	_value = VALUE_DEFAULT
