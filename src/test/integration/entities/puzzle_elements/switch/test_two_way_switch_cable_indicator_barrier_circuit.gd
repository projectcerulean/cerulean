# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends IntegrationTest

const WAIT_FRAMES: int = 10


func test_switch_cable_indicator_barrier_circuit() -> void:
	var test_scene: SwitchCableIndicatorBarrierCircuit =  get_test_scene() as SwitchCableIndicatorBarrierCircuit
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier not enabled after instantiation")

	await wait_for_process_frames(WAIT_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier not enabled a few frames after instantiation")

	test_scene.interaction_manager.perform_interaction()
	await wait_for_process_frames(WAIT_FRAMES)
	assert_true(test_scene.barrier.collision_shape.disabled, "Barrier not disabled after flipping switch")

	test_scene.interaction_manager.perform_interaction()
	await wait_for_process_frames(WAIT_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Barrier not enabled again after flipping switch again")


func get_test_scene_name() -> String:
	return "two_way_switch_cable_indicator_barrier_circuit.tscn"
