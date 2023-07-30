# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends GutTest

const WAIT_FRAMES: int = 10


func test_switch_cable_indicator_barrier_circuit() -> void:
	var test_scene: PackedScene = TestUtils.load_test_scene(self, "switch_cable_indicator_barrier_circuit.tscn")
	var test_scene_instance: SwitchCableIndicatorBarrierCircuit = test_scene.instantiate() as SwitchCableIndicatorBarrierCircuit
	assert(test_scene_instance != null)

	add_child_autofree(test_scene_instance)
	assert_false(test_scene_instance.barrier.collision_shape.disabled)

	await TestUtils.wait_for_process_frames(self, WAIT_FRAMES)
	assert_false(test_scene_instance.barrier.collision_shape.disabled)

	test_scene_instance.switch.flip()
	await TestUtils.wait_for_process_frames(self, WAIT_FRAMES)
	assert_true(test_scene_instance.barrier.collision_shape.disabled)

	test_scene_instance.switch.flip()
	await TestUtils.wait_for_process_frames(self, WAIT_FRAMES)
	assert_false(test_scene_instance.barrier.collision_shape.disabled)
