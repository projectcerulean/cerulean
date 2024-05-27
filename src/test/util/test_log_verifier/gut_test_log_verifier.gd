# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name GutTestLogVerifier
extends Node

const TEST_LOG: String = "res://test_log.txt"
const ALL_TESTS_PASSED_LINE: String = "---- All tests passed! ----"
const ERROR_STRING: String = "ERROR"
const ALLOWED_ERRORS: PackedStringArray = [
	"ERROR: Parameter \"m\" is null.",
]

var verification_ok: bool = false


func perform_verification() -> void:
	var all_tests_passed: bool = false
	var log_errors: Dictionary = {}

	var file: FileAccess = FileAccess.open(TEST_LOG, FileAccess.READ)
	var file_contents: String = file.get_as_text()
	for line: String in file_contents.split("\n", false):
		if line == ALL_TESTS_PASSED_LINE:
			all_tests_passed = true
		if line.contains(ERROR_STRING) and line not in ALLOWED_ERRORS:
			log_errors[line] = null

	if all_tests_passed and log_errors.size() == 0:
		verification_ok = true
	else:
		if not all_tests_passed:
			push_error("Not all tests passed")
		if log_errors.size() > 0:
			var errors: PackedStringArray = PackedStringArray(log_errors.keys())
			errors.sort()
			var error_list_string: String = "Test log contains errors:\n"
			for error: String in errors:
				error_list_string += "    %s\n" % error
			push_error(error_list_string.rstrip("\n"))
