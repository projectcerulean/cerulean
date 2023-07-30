# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TestUtils
extends Node

const GUT_TEST_DIRS: PackedStringArray = [
	"res://src/test/integration/",
	"res://src/test/unit/",
]

const MAIN_SRC_DIR: String = "res://src/"


static func load_scene(test: GutTest, file_name: String) -> PackedScene:
	var resource: Resource = load_resource(test, file_name)
	var scene: PackedScene = resource as PackedScene
	assert(scene != null, "Failed to load scene: " + file_name)
	return scene


static func load_script(test: GutTest, file_name: String) -> Script:
	var resource: Resource = load_resource(test, file_name)
	var script: Script = resource as Script
	assert(script != null, "Failed to load script: " + file_name)
	return script


static func load_resource(test: GutTest, file_name: String) -> Resource:
	var resource_path: String = get_src_path(test) + "/" + file_name
	var resource: Resource = load(resource_path)
	assert(resource != null, "Failed to load resource: " + resource_path)
	return resource


static func load_test_scene(test: GutTest, file_name: String) -> PackedScene:
	var resource: Resource = load_test_resource(test, file_name)
	var scene: PackedScene = resource as PackedScene
	assert(scene != null, "Failed to load test scene: " + file_name)
	return scene


static func load_test_script(test: GutTest, file_name: String) -> Script:
	var resource: Resource = load_test_resource(test, file_name)
	var script: Script = resource as Script
	assert(script != null, "Failed to load test script: " + file_name)
	return script


static func load_test_resource(test: GutTest, file_name: String) -> Resource:
	var resource_path: String = get_script_dir_path(test) + "/" + file_name
	var resource: Resource = load(resource_path)
	assert(resource != null, "Failed to load test resource: " + resource_path)
	return resource


static func get_src_path(test: GutTest) -> String:
	var script_dir_path: String = get_script_dir_path(test)
	for i in range(len(GUT_TEST_DIRS)):
		var gut_test_dir: String = GUT_TEST_DIRS[i]
		var main_src_path = script_dir_path.replace(gut_test_dir, MAIN_SRC_DIR)
		if main_src_path != script_dir_path and DirAccess.dir_exists_absolute(main_src_path):
			return main_src_path

	assert(false, "Failed to get main src path")
	return String()


static func get_script_dir_path(test: GutTest) -> String:
	var script: Script = test.get_script() as Script
	assert(script != null, "Test script is null")
	var script_path: String = script.get_path()
	var dir_name: String = script_path.rsplit("/", false, 1)[0]
	return dir_name


static func wait_for_process_frame(test: GutTest):
	await test.wait_for_signal(test.get_tree().process_frame, 1.0, "Waiting for process frame")


static func wait_for_process_frames(test: GutTest, count: int):
	for i in range(count):
		await test.wait_for_signal(test.get_tree().process_frame, 1.0, "Waiting for process frame %s/%s" % [i + 1, count])


static func wait_for_physics_frame(test: GutTest):
	await test.wait_for_signal(test.get_tree().physics_frame, 1.0, "Waiting for physics frame")


static func wait_for_physics_frames(test: GutTest, count: int):
	for i in range(count):
		await test.wait_for_signal(test.get_tree().physics_frame, 1.0, "Waiting for physics frame %s/%s" % [i + 1, count])
