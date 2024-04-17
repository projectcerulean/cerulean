# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PushButtonCharacterControllerInteractionTestCommon
extends IntegrationTest

const WAIT_PROCESS_FRAMES: int = 5
const COLLISION_TIMEOUT_PHYSICS_FRAMES: int = 60


func test_push_button_character_controller_interaction() -> void:
	var test_scene: PushButtonCharacterControllerInteraction =  get_test_scene() as PushButtonCharacterControllerInteraction
	assert_false(test_scene.barrier.collision_shape.disabled, "Push button immediately pressed after instantiation")

	await wait_for_process_frames(WAIT_PROCESS_FRAMES)
	assert_false(test_scene.barrier.collision_shape.disabled, "Push button already pressed a few frames after instantiation")

	# Wait for the character controller to fall onto the button due to gravity
	var character_controller_y_prev: float = NAN
	var has_collided: bool = false
	for i: int in range(COLLISION_TIMEOUT_PHYSICS_FRAMES):
		if not is_nan(character_controller_y_prev):
			if (
				is_equal_approx(test_scene.character_controller.global_position.y, character_controller_y_prev)
				or test_scene.character_controller.global_position.y > character_controller_y_prev
			):
				has_collided = true
				break
		character_controller_y_prev = test_scene.character_controller.global_position.y
		await wait_for_physics_frame()
	assert_true(has_collided, "Character controller not collide with push button")

	await wait_for_process_frames(WAIT_PROCESS_FRAMES)
	assert_true(test_scene.barrier.collision_shape.disabled, "Push button not pressed after collision with character controller")
