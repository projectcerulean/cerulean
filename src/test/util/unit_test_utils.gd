# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name UnitTestUtils
extends Node


static func search_for_files(search_dir: String, file_pattern: RegEx = null) -> PackedStringArray:
	assert(search_dir.begins_with("res://"), "Invalid search dir: %s" % search_dir)
	if is_instance_valid(file_pattern):
		assert(file_pattern.is_valid(), "Invalid file pattern regex: %s" % file_pattern)
	var found_files: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(search_dir)
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			found_files += search_for_files(search_dir + "/" + file_name, file_pattern)
		else:
			if is_instance_valid(file_pattern):
				var regex_match: RegExMatch = file_pattern.search(file_name)
				if is_instance_valid(regex_match):
					if file_name.length() == regex_match.get_end() - regex_match.get_start():
						found_files.append(search_dir + "/" + file_name)
			else:
				found_files.append(search_dir + "/" + file_name)
		file_name = dir.get_next()
	return found_files
