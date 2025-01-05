# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name IntegrationTest
extends UnitTest

const GAME_STATE_RESOURCE: StateResource = preload("res://src/singletons/game_state_manager/game_state_resource.tres")

var main_scene_instance: Main


# Virtual method, override this in subclasses.
func get_test_scene_name() -> String:
	return String()


func get_test_scene() -> Scene:
	return main_scene_instance.get_current_scene()


func before_each() -> void:
	var test_scene_name: String = get_test_scene_name()
	assert(test_scene_name, Errors.INVALID_ARGUMENT)

	var main_scene_path: String = "res://src/main/main.tscn"
	var main_scene: PackedScene = load(main_scene_path) as PackedScene
	assert(main_scene != null, Errors.NULL_RESOURCE)
	main_scene_instance = main_scene.instantiate() as Main
	assert(main_scene_instance != null, Errors.NULL_NODE)
	main_scene_instance.scene_default = get_script_dir_path() + "/" + test_scene_name
	add_child(main_scene_instance)

	await wait_for_signal(Signals.scene_changed, 10.0)

	for i: int in range(1000):
		if GAME_STATE_RESOURCE.get_current_state() == GameStates.GAMEPLAY:
			break
		await wait_for_process_frame()
	if GAME_STATE_RESOURCE.get_current_state() != GameStates.GAMEPLAY:
		fail_test("Timed out waiting to enter gameplay state")


func after_each() -> void:
	main_scene_instance.free()
