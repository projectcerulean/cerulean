# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Stand-alone script used by the makefile to verify that no unit test failures occurred during the most recent test run.
# Gut/Godot sometimes return zero exit code even if there were failing tests.
extends SceneTree

var JunitTestReportXmlVerifier: PackedScene = load("res://src/test/util/test_report_verifier/junit_test_report_xml_verifier.tscn") as PackedScene


func _init() -> void:
	var main_loop: MainLoop = null
	for i in range(100):
		main_loop = Engine.get_main_loop()
		if main_loop != null:
			break
		await create_timer(0.1).timeout
	if main_loop == null:
		push_error("Failed to get main loop")

	var junit_test_report_xml_verifier: Node = JunitTestReportXmlVerifier.instantiate() as Node
	get_root().add_child(junit_test_report_xml_verifier)

	if junit_test_report_xml_verifier.verification_ok:
		print("JUNIT_TEST_REPORT_XML_VERIFIED_OK")  # parsed by makefile

	quit()
