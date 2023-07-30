# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name UnitTest
extends GutTest


const GUT_TEST_DIRS: PackedStringArray = [
	"res://src/test/integration/",
	"res://src/test/unit/",
]

const MAIN_SRC_DIR: String = "res://src/"


func load_scene(file_name: String) -> PackedScene:
	var resource: Resource = load_resource(file_name)
	var scene: PackedScene = resource as PackedScene
	assert(scene != null, "Failed to load scene: " + file_name)
	return scene


func load_script(file_name: String) -> Script:
	var resource: Resource = load_resource(file_name)
	var script: Script = resource as Script
	assert(script != null, "Failed to load script: " + file_name)
	return script


func load_resource(file_name: String) -> Resource:
	var resource_path: String = _get_main_src_path() + "/" + file_name
	var resource: Resource = load(resource_path)
	assert(resource != null, "Failed to load resource: " + resource_path)
	return resource


func load_test_scene(file_name: String) -> PackedScene:
	var resource: Resource = load_test_resource(file_name)
	var scene: PackedScene = resource as PackedScene
	assert(scene != null, "Failed to load test scene: " + file_name)
	return scene


func load_test_script(file_name: String) -> Script:
	var resource: Resource = load_test_resource(file_name)
	var script: Script = resource as Script
	assert(script != null, "Failed to load test script: " + file_name)
	return script


func load_test_resource(file_name: String) -> Resource:
	var resource_path: String = get_script_dir_path() + "/" + file_name
	var resource: Resource = load(resource_path)
	assert(resource != null, "Failed to load test resource: " + resource_path)
	return resource


func wait_for_process_frame() -> void:
	await wait_for_signal(get_tree().process_frame, 1.0, "Waiting for process frame")


func wait_for_process_frames(count: int) -> void:
	for i in range(count):
		await wait_for_signal(get_tree().process_frame, 1.0, "Waiting for process frame %s/%s" % [i + 1, count])


func wait_for_physics_frame() -> void:
	await wait_for_signal(get_tree().physics_frame, 1.0, "Waiting for physics frame")


func wait_for_physics_frames(count: int) -> void:
	for i in range(count):
		await wait_for_signal(get_tree().physics_frame, 1.0, "Waiting for physics frame %s/%s" % [i + 1, count])


func get_script_dir_path() -> String:
	var script: Script = get_script() as Script
	assert(script != null, "Test script is null")
	var script_path: String = script.get_path()
	var dir_path: String = script_path.rsplit("/", false, 1)[0]
	return dir_path


func _get_main_src_path() -> String:
	var script_dir_path: String = get_script_dir_path()
	for i in range(len(GUT_TEST_DIRS)):
		var gut_test_dir: String = GUT_TEST_DIRS[i]
		var main_src_path = script_dir_path.replace(gut_test_dir, MAIN_SRC_DIR)
		if main_src_path != script_dir_path and DirAccess.dir_exists_absolute(main_src_path):
			return main_src_path

	assert(false, "Failed to get main src path")
	return String()
