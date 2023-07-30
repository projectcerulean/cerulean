# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.000001


func test_signed_sqrt_positive() -> void:
	assert_almost_eq(Math.signed_sqrt(4.0), 2.0, ERROR_INTERVAL)


func test_signed_sqrt_negative() -> void:
	assert_almost_eq(Math.signed_sqrt(-4.0), -2.0, ERROR_INTERVAL)


func test_signed_sqrt_zero() -> void:
	assert_almost_eq(Math.signed_sqrt(0.0), 0.0, ERROR_INTERVAL)
