# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Utils
extends Node


static func calculate_shape_volume(shape: Shape3D) -> float:
	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape as BoxShape3D
		return box_shape.size.x * box_shape.size.y * box_shape.size.z
	else:
		# Not implemented
		return NAN


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


static func str_to_color(string: String) -> Color:
	var color_r: float = (str(string).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	var color_g: float = (str(color_r).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	var color_b: float = (str(color_g).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	return Color(color_r, color_g, color_b).lerp(Color.WHITE, 0.5)
