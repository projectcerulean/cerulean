# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name TestUtils
extends Node

const GUT_TEST_DIRS: PackedStringArray = [
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


static func get_src_path(test: GutTest) -> String:
	var script: Script = test.get_script() as Script
	assert(script != null, "Test script is null")

	var script_path: String = script.get_path()
	var script_dir_path: String = get_dir_name(script_path)
	for i in range(len(GUT_TEST_DIRS)):
		var gut_test_dir: String = GUT_TEST_DIRS[i]
		var main_src_path = script_dir_path.replace(gut_test_dir, MAIN_SRC_DIR)
		if main_src_path != script_dir_path and DirAccess.dir_exists_absolute(main_src_path):
			return main_src_path

	assert(false, "Failed to get main src path")
	return String()


static func get_dir_name(file_path: String) -> String:
	var file_path_stripped: String = file_path.rstrip("/")
	var dir_name: String = file_path_stripped.rsplit("/", false, 1)[0]
	return dir_name
