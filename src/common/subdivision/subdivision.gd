# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Subdivision
extends Node


static func subdivide_color_array(array: PackedColorArray, n_subdivisions: int) -> PackedColorArray:
	var array_subdivided: PackedColorArray = array.duplicate()
	if array_subdivided.size() < 2:
		return array_subdivided

	for i_subdivision in n_subdivisions:
		var array_subdivided_new: PackedColorArray = PackedColorArray()
		array_subdivided_new.resize(2 * array_subdivided.size() - 1)
		for i_point in range(len(array_subdivided)):
			array_subdivided_new[2 * i_point] = array_subdivided[i_point]
		for i_point in range(1, len(array_subdivided_new), 2):
			array_subdivided_new[i_point] = 0.5 * (array_subdivided_new[i_point - 1] + array_subdivided_new[i_point + 1])

		var array_subdivided_new_smoothed: PackedColorArray = PackedColorArray()
		array_subdivided_new_smoothed.resize(array_subdivided_new.size())

		array_subdivided_new_smoothed[0] = array_subdivided_new[0]
		array_subdivided_new_smoothed[-1] = array_subdivided_new[-1]

		for i_point in range(1, len(array_subdivided_new_smoothed) - 1):
			array_subdivided_new_smoothed[i_point] = (
				0.5 * array_subdivided_new[i_point]
				+ 0.25 * array_subdivided_new[i_point - 1]
				+ 0.25 * array_subdivided_new[i_point + 1]
			)
		array_subdivided = array_subdivided_new_smoothed

	return array_subdivided


static func subdivide_float64_array(array: PackedFloat64Array, n_subdivisions: int) -> PackedFloat64Array:
	var array_subdivided: PackedFloat64Array = array.duplicate()
	if array_subdivided.size() < 2:
		return array_subdivided

	for i_subdivision in n_subdivisions:
		var array_subdivided_new: PackedFloat64Array = PackedFloat64Array()
		array_subdivided_new.resize(2 * array_subdivided.size() - 1)
		for i_point in range(len(array_subdivided)):
			array_subdivided_new[2 * i_point] = array_subdivided[i_point]
		for i_point in range(1, len(array_subdivided_new), 2):
			array_subdivided_new[i_point] = 0.5 * (array_subdivided_new[i_point - 1] + array_subdivided_new[i_point + 1])

		var array_subdivided_new_smoothed: PackedFloat64Array = PackedFloat64Array()
		array_subdivided_new_smoothed.resize(array_subdivided_new.size())

		array_subdivided_new_smoothed[0] = array_subdivided_new[0]
		array_subdivided_new_smoothed[-1] = array_subdivided_new[-1]

		for i_point in range(1, len(array_subdivided_new_smoothed) - 1):
			array_subdivided_new_smoothed[i_point] = (
				0.5 * array_subdivided_new[i_point]
				+ 0.25 * array_subdivided_new[i_point - 1]
				+ 0.25 * array_subdivided_new[i_point + 1]
			)
		array_subdivided = array_subdivided_new_smoothed

	return array_subdivided


static func subdivide_vector3_array(array: PackedVector3Array, n_subdivisions: int) -> PackedVector3Array:
	var array_subdivided: PackedVector3Array = array.duplicate()
	if array_subdivided.size() < 2:
		return array_subdivided

	for i_subdivision in n_subdivisions:
		var array_subdivided_new: PackedVector3Array = PackedVector3Array()
		array_subdivided_new.resize(2 * array_subdivided.size() - 1)
		for i_point in range(len(array_subdivided)):
			array_subdivided_new[2 * i_point] = array_subdivided[i_point]
		for i_point in range(1, len(array_subdivided_new), 2):
			array_subdivided_new[i_point] = 0.5 * (array_subdivided_new[i_point - 1] + array_subdivided_new[i_point + 1])

		var array_subdivided_new_smoothed: PackedVector3Array = PackedVector3Array()
		array_subdivided_new_smoothed.resize(array_subdivided_new.size())

		array_subdivided_new_smoothed[0] = array_subdivided_new[0]
		array_subdivided_new_smoothed[-1] = array_subdivided_new[-1]

		for i_point in range(1, len(array_subdivided_new_smoothed) - 1):
			array_subdivided_new_smoothed[i_point] = (
				0.5 * array_subdivided_new[i_point]
				+ 0.25 * array_subdivided_new[i_point - 1]
				+ 0.25 * array_subdivided_new[i_point + 1]
			)
		array_subdivided = array_subdivided_new_smoothed

	return array_subdivided
