# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name NodePathUtils
extends Node


static func get_node_name(node_path: NodePath) -> StringName:
	return node_path.get_name(node_path.get_name_count() - 1)


static func concatenate_paths(path_1: NodePath, path_2: NodePath) -> NodePath:
	assert(path_1.is_absolute(), Errors.NOT_IMPLEMENTED)
	assert(not path_2.is_absolute(), "%s: %s" % [Errors.INVALID_ARGUMENT, [path_1, path_2]])
	var path_names: PackedStringArray = []

	for i: int in range(path_1.get_name_count()):
		var path_name: StringName = path_1.get_name(i)
		if path_name == &".":
			pass
		elif path_name == &"..":
			assert(path_names.size() > 0, "%s: %s" % [Errors.INVALID_ARGUMENT, [path_1, path_2]])
			path_names.remove_at(path_names.size() - 1)
		else:
			path_names.append(path_name)

	for i: int in range(path_2.get_name_count()):
		var path_name: StringName = path_2.get_name(i)
		if path_name == &".":
			pass
		elif path_name == &"..":
			assert(path_names.size() > 0, "%s: %s" % [Errors.INVALID_ARGUMENT, [path_1, path_2]])
			path_names.remove_at(path_names.size() - 1)
		else:
			path_names.append(path_2.get_name(i))

	return NodePath("/" + "/".join(path_names))
