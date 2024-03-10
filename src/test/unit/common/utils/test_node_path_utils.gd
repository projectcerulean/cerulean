# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest


func test_get_node_name() -> void:
	var node_path: NodePath = "Joint/Crystal/Interaction/Action"
	assert_eq(NodePathUtils.get_node_name(node_path), "Action")


func test_get_absolute_path() -> void:
	var node_parent: Node = Node.new()
	var node_child: Node = Node.new()

	node_parent.add_child(node_child)
	add_child_autofree(node_parent)

	var relative_path: NodePath = node_parent.get_path_to(node_child)
	var absolute_path: NodePath = node_child.get_path()

	assert_false(relative_path.is_absolute())
	assert_true(absolute_path.is_absolute())

	assert_eq(NodePathUtils.get_absolute_path(node_parent, relative_path), absolute_path)


func test_get_absolute_path_already_absolute_path() -> void:
	assert_eq(NodePathUtils.get_absolute_path(null, get_path()), get_path())
