# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest


func add_some_miscellaneous_child_nodes(parent: Node) -> void:
	parent.add_child(AudioStreamPlayer3D.new())
	parent.add_child(CPUParticles3D.new())
	parent.add_child(VBoxContainer.new())
	parent.add_child(VehicleWheel3D.new())


func test_get_collision_shape_for_area() -> void:
	var area: Area3D = Area3D.new()
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	add_some_miscellaneous_child_nodes(area)
	area.add_child(collision_shape)
	add_some_miscellaneous_child_nodes(area)

	assert_same(collision_shape, TreeUtils.get_collision_shape_for_area(area))

	area.free()


func test_get_collision_shape_for_area_no_collision_shape() -> void:
	var area: Area3D = Area3D.new()
	add_some_miscellaneous_child_nodes(area)

	assert_null(TreeUtils.get_collision_shape_for_area(area))

	area.free()


func test_get_collision_shape_for_body() -> void:
	var body: RigidBody3D = RigidBody3D.new()
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	add_some_miscellaneous_child_nodes(body)
	body.add_child(collision_shape)
	add_some_miscellaneous_child_nodes(body)

	assert_same(collision_shape, TreeUtils.get_collision_shape_for_body(body))

	body.free()


func test_get_collision_shape_for_body_no_collision_shape() -> void:
	var body: RigidBody3D = RigidBody3D.new()
	add_some_miscellaneous_child_nodes(body)

	assert_null(TreeUtils.get_collision_shape_for_body(body))

	body.free()


func test_reparent_node() -> void:
	var parent_prev: Node = Node.new()
	var parent_new: Node = Node.new()
	var node: Node = Node.new()
	parent_prev.add_child(node)
	assert_same(parent_prev, node.get_parent())

	var node_reparented: bool = TreeUtils.reparent_node(node, parent_new)
	assert_true(node_reparented)
	assert_same(parent_new, node.get_parent())

	node.free()
	parent_prev.free()
	parent_new.free()


func test_reparent_node_no_change() -> void:
	var parent: Node = Node.new()
	var node: Node = Node.new()
	parent.add_child(node)
	assert_same(parent, node.get_parent())

	var node_reparented: bool = TreeUtils.reparent_node(node, parent)
	assert_false(node_reparented)
	assert_same(parent, node.get_parent())

	node.free()
	parent.free()


func test_reparent_node_no_initial_parent() -> void:
	var parent_new: Node = Node.new()
	var node: Node = Node.new()
	assert_null(node.get_parent())

	var node_reparented: bool = TreeUtils.reparent_node(node, parent_new)
	assert_true(node_reparented)
	assert_same(parent_new, node.get_parent())

	node.free()
	parent_new.free()
