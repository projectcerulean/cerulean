# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Checks that all GDScript files can be parsed without errors. Any errors are detected by the test
# log verifier.
extends UnitTest

const SRC_DIR: String = "res://src"

var script_files: Array = _get_script_files()


func test_script_parsing(params: Array = use_parameters(script_files)) -> void:
	@warning_ignore("unsafe_cast")
	var script_file: String = params[0] as String
	var script_resource: Script = load(script_file) as Script
	assert_not_null(script_resource, "Failed to load: %s" % script_file)


func _get_script_files() -> Array:
	var found_script_files: PackedStringArray = UnitTestUtils.search_for_files(SRC_DIR, RegEx.create_from_string(".*\\.gd"))
	assert(found_script_files.size() > 0, Errors.CONSISTENCY_ERROR)
	var files: Array = []

	for i: int in range(len(found_script_files)):
		files.append([found_script_files[i]])

	return files
