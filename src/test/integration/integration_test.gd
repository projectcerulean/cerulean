# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name IntegrationTest
extends UnitTest

var main_scene_instance: Node


# Virtual method, override this in subclasses.
func get_test_scene_name() -> String:
	return String()


func get_test_scene() -> Node:
	var scene_manager: SceneManager = _get_scene_manager()
	assert(scene_manager.get_child_count() == 1, Errors.CONSISTENCY_ERROR)
	return scene_manager.get_child(0)


func before_each() -> void:
	var test_scene_name: String = get_test_scene_name()
	assert(test_scene_name, Errors.INVALID_ARGUMENT)

	var main_scene_path: String = "res://src/main/main.tscn"
	var main_scene: PackedScene = load(main_scene_path) as PackedScene
	assert(main_scene != null, Errors.NULL_RESOURCE)
	main_scene_instance = main_scene.instantiate()
	assert(main_scene_instance != null, Errors.NULL_NODE)

	var scene_manager = _get_scene_manager()
	scene_manager.scene_default = get_script_dir_path() + "/" + test_scene_name

	add_child(main_scene_instance)

	await wait_for_signal(Signals.scene_changed, 10.0)


func after_each() -> void:
	main_scene_instance.free()


func _get_scene_manager() -> SceneManager:
	var scene_manager: SceneManager = main_scene_instance.get_node("Singletons/SceneManager") as SceneManager
	assert(scene_manager != null, Errors.NULL_NODE)
	return scene_manager
