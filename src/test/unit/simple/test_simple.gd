# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest


func test_assert_true() -> void:
	assert_true(true)


func test_assert_false() -> void:
	assert_false(false)
