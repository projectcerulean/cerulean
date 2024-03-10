# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name NodePathUtils
extends Node


static func get_node_name(node_path: NodePath) -> StringName:
	return node_path.get_name(node_path.get_name_count() - 1)


static func get_absolute_path(caller: Node, node_path: NodePath) -> NodePath:
	if node_path.is_absolute():
		return node_path
	var node: Node = caller.get_node(node_path)
	assert(node != null, Errors.NULL_NODE)
	return node.get_path()
