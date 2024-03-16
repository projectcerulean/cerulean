# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Stand-alone script used by the makefile to verify that no unit test failures occurred during the most recent test run.
# Gut/Godot sometimes return zero exit code even if there were failing tests.
extends SceneTree

const gutconfig_json: String = "res://.gutconfig.json"
const junit_test_report_xml: String = "res://test_report.xml"


func _init() -> void:
	var test_dirs: PackedStringArray = get_test_dirs()
	if test_dirs.size() > 0:
		var test_scripts: PackedStringArray = []
		for test_dir: String in test_dirs:
			var found_test_scripts: PackedStringArray = find_test_scripts(test_dir)
			test_scripts += found_test_scripts
		if test_scripts.size() > 0:
			var test_methods: Dictionary = find_test_methods(test_scripts)
			if test_methods.size() > 0:
				if verify_junit_xml_file(test_methods):
					print("JUNIT_TEST_REPORT_XML_VERIFIED_OK")  # parsed by makefile
	quit()


func get_test_dirs() -> PackedStringArray:
	var file: FileAccess = FileAccess.open(gutconfig_json, FileAccess.READ)
	var file_contents: String = file.get_as_text()
	var json_contents: Dictionary = JSON.parse_string(file_contents)
	var dirs: PackedStringArray = []
	for dir: String in json_contents[&"dirs"]:
		dirs.append(dir.trim_suffix("/"))
	return dirs


func find_test_scripts(test_dir: String) -> PackedStringArray:
	var found_test_scripts: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(test_dir)
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			found_test_scripts += find_test_scripts(test_dir + "/" + file_name)
		else:
			if file_name.ends_with(".gd"):
				found_test_scripts.append(test_dir + "/" + file_name)
		file_name = dir.get_next()
	return found_test_scripts


func find_test_methods(test_scripts: PackedStringArray) -> Dictionary:
	var test_methods: Dictionary = {}
	var test_method_regex: RegEx = RegEx.create_from_string("^func\\s+(test_[^\\(]+).*:$")
	for test_script: String in test_scripts:
		var test_script_file: FileAccess = FileAccess.open(test_script, FileAccess.READ)
		var test_script_contents: String = test_script_file.get_as_text()
		for line: String in test_script_contents.split("\n"):
			var regex_matches: Array[RegExMatch] = test_method_regex.search_all(line)
			for regex_match: RegExMatch in regex_matches:
				if test_script not in test_methods:
					test_methods[test_script] = []
				test_methods[test_script].append(regex_match.get_string(1).strip_edges())
	return test_methods


func verify_junit_xml_file(test_methods: Dictionary) -> bool:
	var expected_total_test_count: int = 0
	for test_script: String in test_methods:
		expected_total_test_count += len(test_methods[test_script])

	var xmlParser: XMLParser = XMLParser.new()
	xmlParser.open(junit_test_report_xml)

	# Verify testsuites node
	var total_test_count_ok: bool = false
	var total_failure_count_ok: bool = false
	xmlParser.seek(0)
	while xmlParser.read() != ERR_FILE_EOF:
		if xmlParser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name: String = xmlParser.get_node_name()
			if node_name == "testsuites":
				for i in range(xmlParser.get_attribute_count()):
					if xmlParser.get_attribute_name(i) == "tests":
						if xmlParser.get_attribute_value(i).is_valid_int():
							if xmlParser.get_attribute_value(i).to_int() == expected_total_test_count:
								total_test_count_ok = true
					if xmlParser.get_attribute_name(i) == "failures":
						if xmlParser.get_attribute_value(i).is_valid_int():
							if xmlParser.get_attribute_value(i).to_int() == 0:
								total_failure_count_ok = true
	if not total_test_count_ok or not total_failure_count_ok:
		return false

	# Verify testsuite nodes
	for test_script: String in test_methods:
		var expected_test_count: int = len(test_methods[test_script])
		var test_count_ok: bool = false
		var failure_count_ok: bool = false
		var skipped_count_ok: bool = false
		xmlParser.seek(0)
		while xmlParser.read() != ERR_FILE_EOF:
			if xmlParser.get_node_type() == XMLParser.NODE_ELEMENT:
				var node_name: String = xmlParser.get_node_name()
				if node_name == "testsuite":
					for i in range(xmlParser.get_attribute_count()):
						if xmlParser.get_attribute_name(i) == "name":
							if xmlParser.get_attribute_value(i) == test_script:
								for j in range(xmlParser.get_attribute_count()):
									if xmlParser.get_attribute_name(j) == "tests":
										if xmlParser.get_attribute_value(j).is_valid_int():
											if xmlParser.get_attribute_value(j).to_int() == expected_test_count:
												test_count_ok = true
									if xmlParser.get_attribute_name(j) == "failures":
										if xmlParser.get_attribute_value(j).is_valid_int():
											if xmlParser.get_attribute_value(j).to_int() == 0:
												failure_count_ok = true
									if xmlParser.get_attribute_name(j) == "skipped":
										if xmlParser.get_attribute_value(j).is_valid_int():
											if xmlParser.get_attribute_value(j).to_int() == 0:
												skipped_count_ok = true
		if not test_count_ok or not failure_count_ok or not skipped_count_ok:
			return false

	# Verify testcase nodes
	for test_script: String in test_methods:
		for test_method: String in test_methods[test_script]:
			var status_ok: bool = false
			var assertion_count_ok: bool = false
			xmlParser.seek(0)
			while xmlParser.read() != ERR_FILE_EOF:
				if xmlParser.get_node_type() == XMLParser.NODE_ELEMENT:
					var node_name: String = xmlParser.get_node_name()
					if node_name == "testcase":
						for i in range(xmlParser.get_attribute_count()):
							if xmlParser.get_attribute_name(i) == "name":
								if xmlParser.get_attribute_value(i) == test_method:
									for j in range(xmlParser.get_attribute_count()):
										if xmlParser.get_attribute_name(j) == "classname":
											if xmlParser.get_attribute_value(j) == test_script:
												for k in range(xmlParser.get_attribute_count()):
													if xmlParser.get_attribute_name(k) == "status":
														if xmlParser.get_attribute_value(k) == "pass":
															status_ok = true
													if xmlParser.get_attribute_name(k) == "assertions":
														if xmlParser.get_attribute_value(k).is_valid_int():
															if xmlParser.get_attribute_value(k).to_int() > 0:
																assertion_count_ok = true
			if not status_ok or not assertion_count_ok:
				return false

	return true
