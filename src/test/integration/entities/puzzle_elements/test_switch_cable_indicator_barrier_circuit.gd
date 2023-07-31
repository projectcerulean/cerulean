# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends IntegrationTest

const WAIT_FRAMES: int = 10


func get_test_scene_name() -> String:
	return "switch_cable_indicator_barrier_circuit.tscn"


func test_switch_cable_indicator_barrier_circuit() -> void:
	var test_scene: SwitchCableIndicatorBarrierCircuit =  get_test_scene() as SwitchCableIndicatorBarrierCircuit
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier enabled after instantiation")

	await wait_for_process_frames(WAIT_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier still enabled a few frames after instantiation")

	test_scene.switch_interaction_action.interact()
	await wait_for_process_frames(WAIT_FRAMES)
	assert_true(test_scene.barrier.collision_shape.disabled, "Barrier disabled after flipping switch")

	test_scene.switch_interaction_action.interact()
	await wait_for_process_frames(WAIT_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier enabled again after flipping switch again")
