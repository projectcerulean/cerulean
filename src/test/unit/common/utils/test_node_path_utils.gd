# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest


func test_get_node_name() -> void:
	var node_path: NodePath = "Joint/Crystal/Interaction/Action"
	assert_eq(NodePathUtils.get_node_name(node_path), "Action")


func test_concatenate_simple() -> void:
	verify_concatenation(^"/root/Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")


func test_concatenate_trailing_slash() -> void:
	verify_concatenation(^"/root/Node/", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node/", ^"Child1/Child2/", ^"/root/Node/Child1/Child2")


func test_concatenate_double_slash() -> void:
	verify_concatenation(^"//root/Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root//Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1//Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/Child2//", ^"/root/Node/Child1/Child2")


func test_concatenate_dot() -> void:
	verify_concatenation(^"/./root/Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/./Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node/.", ^"Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"./Child1/Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/./Child2", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/.", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/./", ^"/root/Node/Child1/Child2")
	verify_concatenation(^"/root/./././Node", ^"Child1/Child2", ^"/root/Node/Child1/Child2")


func test_concatenate_double_dot() -> void:
	verify_concatenation(^"/root/../Node", ^"Child1/Child2", ^"/Node/Child1/Child2")
	verify_concatenation(^"/root/Node/..", ^"Child1/Child2", ^"/root/Child1/Child2")
	verify_concatenation(^"/root/Node/../", ^"Child1/Child2", ^"/root/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"../Child1/Child2", ^"/root/Child1/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/../Child2", ^"/root/Node/Child2")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/..", ^"/root/Node/Child1")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/../", ^"/root/Node/Child1")
	verify_concatenation(^"/root/Node", ^"Child1/Child2/../../", ^"/root/Node")
	verify_concatenation(^"/root/../Node", ^"Child1/Child2/..", ^"/Node/Child1")


func verify_concatenation(path_1: NodePath, path_2: NodePath, concatenation: NodePath) -> void:
	assert_eq(NodePathUtils.concatenate_paths(path_1, path_2), concatenation)
