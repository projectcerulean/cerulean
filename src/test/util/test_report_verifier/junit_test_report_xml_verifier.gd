# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

const gutconfig_json: String = "res://.gutconfig.json"
const junit_test_report_xml: String = "res://test_report.xml"

var verification_ok: bool = false


func _ready() -> void:
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
					verification_ok = true
					return
			else:
				push_error("No test methods found")
		else:
			push_error("No test scripts found")
	else:
		push_error("No testdirs found")
	push_error("Verification of '", junit_test_report_xml, "' failed")


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
			if file_name.begins_with("test_") and file_name.ends_with(".gd"):
				found_test_scripts.append(test_dir + "/" + file_name)
		file_name = dir.get_next()
	return found_test_scripts


func find_test_methods(test_scripts: PackedStringArray) -> Dictionary:
	var test_methods: Dictionary = {}
	for test_script: String in test_scripts:
		test_methods[test_script] = []
		var script_resource: Script = load(test_script) as Script
		for method: Dictionary in script_resource.get_script_method_list():
			var method_name: String = String(method[&"name"])
			if method_name.begins_with("test_"):
				test_methods[test_script].append(method_name)
	return test_methods


func verify_junit_xml_file(test_methods: Dictionary) -> bool:
	var xmlParser: XMLParser = XMLParser.new()
	xmlParser.open(junit_test_report_xml)

	# Verify testcase nodes
	for test_script: String in test_methods:
		for test_method: String in test_methods[test_script]:
			var status_ok: bool = false
			var assertion_count_ok: bool = false
			var status: String = String()
			var assertion_count: int = -1
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
														status = xmlParser.get_attribute_value(k)
													if xmlParser.get_attribute_name(k) == "assertions":
														if xmlParser.get_attribute_value(k).is_valid_int():
															assertion_count = xmlParser.get_attribute_value(k).to_int()
			if status != "pass":
				push_error(test_script, "#", test_method, ": status not ok (was '", status, "')")
				return false
			if not assertion_count > 0:
				push_error(test_script, "#", test_method, ": assertion count non-positive (was ", assertion_count, ")")
				return false

	# Verify testsuite nodes
	for test_script: String in test_methods:
		var expected_test_count: int = len(test_methods[test_script])
		if not expected_test_count > 0:
			push_error(test_script, ": no tests found")
			return false

		var test_count: int = -1
		var failure_count: int = -1
		var skipped_count: int = -1
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
											test_count = xmlParser.get_attribute_value(j).to_int()
									if xmlParser.get_attribute_name(j) == "failures":
										if xmlParser.get_attribute_value(j).is_valid_int():
											failure_count = xmlParser.get_attribute_value(j).to_int()
									if xmlParser.get_attribute_name(j) == "skipped":
										if xmlParser.get_attribute_value(j).is_valid_int():
											skipped_count = xmlParser.get_attribute_value(j).to_int()
		if test_count != expected_test_count:
			push_error(test_script, ": test count not OK (was ", test_count, ", expected ", expected_test_count, ")")
			return false
		if failure_count != 0:
			push_error(test_script, ": test failure count not zero (was ", failure_count, ")")
			return false
		if skipped_count != 0:
			push_error(test_script, ": skipped test count not zero (was ", skipped_count, ")")
			return false

	# Verify testsuites node
	var expected_total_test_count: int = 0
	for test_script: String in test_methods:
		expected_total_test_count += len(test_methods[test_script])
	if not expected_total_test_count > 0:
		push_error("no tests found")
		return false
	var total_test_count: int = -1
	var total_failure_count: int = -1
	xmlParser.seek(0)
	while xmlParser.read() != ERR_FILE_EOF:
		if xmlParser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name: String = xmlParser.get_node_name()
			if node_name == "testsuites":
				for i in range(xmlParser.get_attribute_count()):
					if xmlParser.get_attribute_name(i) == "tests":
						if xmlParser.get_attribute_value(i).is_valid_int():
							total_test_count = xmlParser.get_attribute_value(i).to_int()
					if xmlParser.get_attribute_name(i) == "failures":
						if xmlParser.get_attribute_value(i).is_valid_int():
							total_failure_count = xmlParser.get_attribute_value(i).to_int()
	if total_test_count != expected_total_test_count:
		push_error("Total test count not OK (was ", total_test_count, ", expected ", expected_total_test_count, ")")
		return false
	if total_failure_count != 0:
		push_error("Total test failure count not zero (was ", total_failure_count, ")")
		return false

	return true
