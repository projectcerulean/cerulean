# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Checks that all scene files can be loaded and be instantiated without errors. Note that most
# types of errors are catched by the test log verifier, not by the asserts in the test.
extends UnitTest

const SRC_DIR: String = "res://src"
const WAIT_FRAMES: int = 2


var scene_files: Array = _get_scene_files()


func test_scene_instantiation(params=use_parameters(scene_files)) -> void:
	var scene_file: String = params[0] as String
	await _perform_scene_instantiation_test(scene_file, false)


func test_scene_instantiation_add_to_scene_tree(params=use_parameters(scene_files)) -> void:
	var scene_file: String = params[0] as String
	await _perform_scene_instantiation_test(scene_file, true)


func _perform_scene_instantiation_test(scene_file: String, add_to_scene_tree: bool) -> void:
	var packed_scene: PackedScene = load(scene_file) as PackedScene
	assert_not_null(packed_scene, "Failed to load: %s" % scene_file)

	var node: Node = packed_scene.instantiate()
	assert_not_null(node, "Failed to instatiate: %s" % scene_file)

	var node_configuration_warnings: PackedStringArray = []
	for d: Dictionary in node.get_method_list():
		if d[&"name"] == &"_get_configuration_warnings" and not d[&"flags"] & METHOD_FLAG_VIRTUAL:
			node_configuration_warnings.append_array(node._get_configuration_warnings())

	if add_to_scene_tree:
		if node_configuration_warnings.is_empty():
			add_child(node)
		else:
			gut_print(
				"Scene %s has %s configuration warning(s): %s, skipping adding to scene tree."
				% [scene_file, node_configuration_warnings.size(), node_configuration_warnings],
			)
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)

	node.free()
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)


func _get_scene_files() -> Array:
	var found_scene_files: PackedStringArray = UnitTestUtils.search_for_files(SRC_DIR, RegEx.create_from_string(".*\\.tscn"))
	assert(found_scene_files.size() > 0, Errors.CONSISTENCY_ERROR)
	var files: Array = []

	for i in range(len(found_scene_files)):
		files.append([found_scene_files[i]])

	return files
