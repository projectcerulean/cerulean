# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.000001
const LERP_VALUE_FROM: float = 1.0
const LERP_VALUE_TO: float = 0.0
const LERP_WEIGHT: float = 2.0
const END_TIME_SECONDS: int = 1.0
const EXPECTED_LOG_SLOPE: float = log(pow(10.0, -LERP_WEIGHT))

const test_params = [
	[1.0 / 60.0],
	[1.0 / 120.0],
	[1.0 / 240.0],
	[1.0 / 360.0],
]

func test_delta_lerp(params=use_parameters(test_params)) -> void:
	var process_delta: float = params[0]
	assert_gt(process_delta, 0.0, "Invalid process delta")

	var timestamps: PackedFloat64Array = [0.0]
	var values_lerped: PackedFloat64Array = [LERP_VALUE_FROM]

	while timestamps[-1] < END_TIME_SECONDS:
		timestamps.append(timestamps[-1] + process_delta)
		values_lerped.append(Lerp.delta_lerp(values_lerped[-1], LERP_VALUE_TO, LERP_WEIGHT, process_delta))
	assert_gt(len(timestamps), 1, "Fewer that 2 data points")
	assert_eq(len(values_lerped), len(timestamps), "Not the same number of timestamps (x-values) and lerp values (y-values)")

	for i in range(len(timestamps)):
		var logged_lerp_value: float = log(values_lerped[i])
		var expected_logged_lerp_value: float = get_expected_log_lerp_value(timestamps[i])
		assert_almost_eq(logged_lerp_value, expected_logged_lerp_value, ERROR_INTERVAL, "Unexpected log lerp value")


func get_expected_log_lerp_value(timestamp: float) -> float:
	return timestamp * EXPECTED_LOG_SLOPE
