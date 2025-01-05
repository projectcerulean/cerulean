# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Stand-alone script used by the makefile to verify that no unit test failures occurred during the most recent test run.
# Gut/Godot sometimes return zero exit code even if there were failing tests.
extends ExecScript

var JunitTestReportXmlVerifierPreload: PackedScene = load("res://src/test/util/test_report_verifier/junit_test_report_xml_verifier.tscn") as PackedScene


func main() -> void:
	var junit_test_report_xml_verifier: JunitTestReportXmlVerifier = JunitTestReportXmlVerifierPreload.instantiate() as JunitTestReportXmlVerifier
	get_root().add_child(junit_test_report_xml_verifier)
	junit_test_report_xml_verifier.perform_verification()
	if junit_test_report_xml_verifier.verification_ok:
		print("JUNIT_TEST_REPORT_XML_VERIFIED_OK")  # parsed by makefile
