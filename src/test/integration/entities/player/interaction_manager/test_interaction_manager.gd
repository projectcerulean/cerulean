# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends IntegrationTest

const WAIT_FRAMES: int = 2
const STATE_1: StringName = &"State1"
const STATE_2: StringName = &"State2"


## Checks that the correct interactable gets highlighted, depending on the location of the
## interaction manager. The test scene has two overlapping areas, requring the interaction manager
## to correctly choose the closest one.
func test_enter_exit_interaction_area_range() -> void:
	watch_signals(Signals)
	var test_scene: InteractionManagerTestScene = get_test_scene() as InteractionManagerTestScene

	var n_state_entered_signals_prev: int = get_signal_emit_count(Signals, Signals.state_entered.get_name())
	var n_state_exited_signals_prev: int = get_signal_emit_count(Signals, Signals.state_exited.get_name())

	# Start outside of interactable areas
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.closest_interactable_changed.get_name(), 0, "Expected no closest_interactable_changed signals before entering any interaction areas")

	# Move to center of first interactable area
	test_scene.interaction_manager.global_position = test_scene.interactable_1.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.closest_interactable_changed.get_name(), 1, "Expected exactly one closest_interactable_changed signal after moving to center of first area")
	assert_signal_emitted_with_parameters(Signals, Signals.closest_interactable_changed.get_name(), [
		test_scene.interaction_manager.get_path(),
		test_scene.interactable_1.get_path(),
	])

	# Move to center of second interactable area
	test_scene.interaction_manager.global_position = test_scene.interactable_2.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.closest_interactable_changed.get_name(), 2, "Expected exactly two closest_interactable_changed signal after moving to center of second area")
	assert_signal_emitted_with_parameters(Signals, Signals.closest_interactable_changed.get_name(), [
		test_scene.interaction_manager.get_path(),
		test_scene.interactable_2.get_path(),
	])

	# Move out of interactable areas
	test_scene.interaction_manager.global_position = test_scene.end_position.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.closest_interactable_changed.get_name(), 3, "Expected exactly three closest_interactable_changed signal after leaving areas")
	assert_signal_emitted_with_parameters(Signals, Signals.closest_interactable_changed.get_name(), [
		test_scene.interaction_manager.get_path(),
		NodePath(),
	])

	# There should have been no interactions during the test, since none of the interactables have been interacted with
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), 0, "Expected no interactions, since the interactables have not been interacted with")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev, "Expected no new state_entered signals during the test, since there have been no interactions")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev, "Expected no new state_exited signals during the test, since there have been no interactions")


## Checks that the correct interactable gets interacted with, depending on the location of the
## interaction manager.
func test_interaction() -> void:
	watch_signals(Signals)
	var test_scene: InteractionManagerTestScene = get_test_scene() as InteractionManagerTestScene

	var n_state_entered_signals_prev: int = get_signal_emit_count(Signals, Signals.state_entered.get_name())
	var n_state_exited_signals_prev: int = get_signal_emit_count(Signals, Signals.state_exited.get_name())

	var n_expected_interactions: int = 0

	# Start outside of interactable areas
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions yet, since no interactions performed")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions yet, since no interactions performed")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions yet, since no interactions performed")

	# Try to interact with nothing
	test_scene.interaction_manager.perform_interaction()
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions yet, since all interactibles are out of range")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions yet, since all interactibles are out of range")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions yet, since all interactibles are out of range")

	# Move to center of first interactable area
	test_scene.interaction_manager.global_position = test_scene.interactable_1.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")

	test_scene.interaction_manager.perform_interaction()
	n_expected_interactions += 1
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected exactly one interaction after trying to interact with the first area")
	assert_signal_emitted_with_parameters(Signals, Signals.closest_interactable_changed.get_name(), [
		test_scene.interaction_manager.get_path(),
		test_scene.interactable_1.get_path(),
	])
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected exactly one new state_exited signal after the first interaction action")
	assert_signal_emitted_with_parameters(Signals, Signals.state_exited.get_name(), [
		test_scene.state_machine_1.get_path(),
		STATE_1,
		{
			State.NEW_STATE: STATE_2,
			State.OLD_STATE: STATE_1,
		},
	])
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected exactly one new state_entered signal after the first interaction action")
	assert_signal_emitted_with_parameters(Signals, Signals.state_entered.get_name(), [
		test_scene.state_machine_1.get_path(),
		STATE_2,
		{
			State.NEW_STATE: STATE_2,
			State.OLD_STATE: STATE_1,
		},
	])

	# Move to center of second interactable area
	test_scene.interaction_manager.global_position = test_scene.interactable_2.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions yet, since the interactable has not been interacted with yet")

	test_scene.interaction_manager.perform_interaction()
	n_expected_interactions += 1
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected exactly one new interaction after trying to interact with the second area")
	assert_signal_emitted_with_parameters(Signals, Signals.closest_interactable_changed.get_name(), [
		test_scene.interaction_manager.get_path(),
		test_scene.interactable_2.get_path(),
	])
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected exactly one new state_exited signal after the second interaction")
	assert_signal_emitted_with_parameters(Signals, Signals.state_exited.get_name(), [
		test_scene.state_machine_2.get_path(),
		STATE_1,
		{
			State.NEW_STATE: STATE_2,
			State.OLD_STATE: STATE_1,
		},
	])
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected exactly one new state_entered signal after the second interaction")
	assert_signal_emitted_with_parameters(Signals, Signals.state_entered.get_name(), [
		test_scene.state_machine_2.get_path(),
		STATE_2,
		{
			State.NEW_STATE: STATE_2,
			State.OLD_STATE: STATE_1,
		},
	])

	# Move out of interactable areas
	test_scene.interaction_manager.global_position = test_scene.end_position.global_position
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions after moving out of the areas")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions after moving out of the areas")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions after moving out of the areas")

	# Try to interact with nothing, again
	test_scene.interaction_manager.perform_interaction()
	await wait_for_process_frames(WAIT_FRAMES)
	await wait_for_physics_frames(WAIT_FRAMES)
	assert_signal_emit_count(Signals, Signals.interaction_performed.get_name(), n_expected_interactions, "Expected no new interactions, since no interactibles are in range anymore")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), n_state_entered_signals_prev + n_expected_interactions, "Expected no new interactions, since no interactibles are in range anymore")
	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), n_state_exited_signals_prev + n_expected_interactions, "Expected no new interactions, since no interactibles are in range anymore")


func get_test_scene_name() -> String:
	return "interaction_manager_test_scene.tscn"
