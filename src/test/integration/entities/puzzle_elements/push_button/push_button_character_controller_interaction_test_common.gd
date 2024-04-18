# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PushButtonCharacterControllerInteractionTestCommon
extends IntegrationTest

const INITIAL_WAIT_PROCESS_FRAMES: int = 3
const MAX_WAIT_PHYSICS_FRAMES: int = 60


func test_push_button_character_controller_interaction() -> void:
	var test_scene: PushButtonCharacterControllerInteraction =  get_test_scene() as PushButtonCharacterControllerInteraction
	assert_false(test_scene.barrier.collision_shape.disabled, "Push button immediately pressed after instantiation")

	await wait_for_process_frames(INITIAL_WAIT_PROCESS_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Push button already pressed a few frames after instantiation")

	# Wait for the character controller to fall onto the button due to gravity
	for i: int in range(MAX_WAIT_PHYSICS_FRAMES):
		await wait_for_physics_frame()
		if test_scene.barrier.collision_shape.disabled:
			break
	assert_true(test_scene.barrier.collision_shape.disabled, "Push button not pressed after collision with character controller")

	# Push the character controller off of the button
	test_scene.character_controller.apply_central_impulse(1000.0 * Vector3.FORWARD * test_scene.character_controller.mass)
	for i: int in range(MAX_WAIT_PHYSICS_FRAMES):
		await wait_for_physics_frame()
		if not test_scene.barrier.collision_shape.disabled:
			break
	assert_false(test_scene.barrier.collision_shape.disabled, "Push button still pressed after moving character controller off of it")
