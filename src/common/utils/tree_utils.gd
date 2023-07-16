# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TreeUtils
extends Node


static func get_collision_shape_for_area(area: Area3D) -> CollisionShape3D:
	var collision_shape: CollisionShape3D = null
	for child in area.get_children():
		if child as CollisionShape3D != null:
			collision_shape = child
			break
	return collision_shape


static func get_collision_shape_for_body(body: PhysicsBody3D) -> CollisionShape3D:
	var collision_shape: CollisionShape3D = null
	for child in body.get_children():
		if child as CollisionShape3D != null:
			collision_shape = child
			break
	return collision_shape


static func reparent_node(node: Node, parent_new: Node) -> bool:
	assert(node != null, Errors.NULL_NODE)
	assert(parent_new != null, Errors.NULL_NODE)
	var parent_prev: Node = node.get_parent()
	if parent_new == parent_prev:
		return false
	if parent_prev != null:
		parent_prev.remove_child(node)
	parent_new.add_child(node)
	return true
