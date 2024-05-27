# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const positions: PackedVector3Array = [
	Vector3(1.0, 2.0, 3.0),
	Vector3(4.0, 5.0, 6.0),
	Vector3(7.0, 8.0, 9.0),
]

var transform_resource: TransformResource
var transform_resource_manager: TransformResourceManager
var anchor_node: Node3D


func before_each() -> void:
	super.before_each()

	transform_resource = TransformResource.new()
	assert_false(transform_resource.is_owned(), "Transform resource already owned immediately after being created")

	var transform_resource_manager_scene: PackedScene = load_scene("transform_resource_manager.tscn")
	transform_resource_manager = transform_resource_manager_scene.instantiate() as TransformResourceManager
	assert(transform_resource_manager != null, Errors.NULL_NODE)

	anchor_node = Node3D.new()
	add_child(anchor_node)
	anchor_node.global_position = positions[0]

	transform_resource_manager.transform_resource = transform_resource
	anchor_node.add_child(transform_resource_manager)
	assert_true(transform_resource.is_owned(), "Transform resource not owned after transform resource manager added")
	assert_eq(transform_resource.get_value(), anchor_node.global_transform, "Transform resource not updated when entering tree")


func after_each() -> void:
	transform_resource_manager.free()
	anchor_node.free()
	assert_false(transform_resource.is_owned(), "Transform resource still onwed after node was deleted")


func test_transform_resource_updates_on_process_update() -> void:
	for position: Vector3 in positions:
		anchor_node.global_position = position
		await wait_for_process_frame()
		assert_eq(transform_resource.get_value(), anchor_node.global_transform, "Transform resource not updated on process update")


func test_transform_resource_updates_on_scene_changed() -> void:
	transform_resource_manager.set_process(false)
	for position: Vector3 in positions:
		anchor_node.global_position = position
		Signals.emit_scene_changed(self)
		await wait_for_signal(Signals.scene_changed, 1.0, "Waiting for scene_changed signal")
		assert_eq(transform_resource.get_value(), anchor_node.global_transform, "Transform resource not updated on scene_changed signal")
