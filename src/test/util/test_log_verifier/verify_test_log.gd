# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Stand-alone script used by the makefile to verify that no errors occurred during the most recent test run.
extends ExecScript

var GutTestLogVerifierPreload: PackedScene = load("res://src/test/util/test_log_verifier/gut_test_log_verifier.tscn") as PackedScene


func main() -> void:
	var gut_test_log_verifier: GutTestLogVerifier = GutTestLogVerifierPreload.instantiate() as GutTestLogVerifier
	get_root().add_child(gut_test_log_verifier)
	gut_test_log_verifier.perform_verification()
	if gut_test_log_verifier.verification_ok:
		print("TEST_LOG_VERIFIED_OK")  # parsed by makefile
