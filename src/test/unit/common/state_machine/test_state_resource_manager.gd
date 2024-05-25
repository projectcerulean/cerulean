# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const test_state_resource_manager_params = [
	[[], true],
	[[], false],
	[[&"state_1", &"state_2", &"state_3"], true],
	[[&"state_1", &"state_2", &"state_3"], false],
]


func test_state_resource_manager(params=use_parameters(test_state_resource_manager_params)):
	var states: Array = params[0]
	var is_correct_state_machine_emitting: bool = params[1]

	var state_machine_dummy_target: Node = Node.new()
	add_child_autofree(state_machine_dummy_target)
	var state_machine_dummy_emitting: Node = state_machine_dummy_target
	if not is_correct_state_machine_emitting:
		state_machine_dummy_emitting = Node.new()
		add_child_autofree(state_machine_dummy_emitting)

	var state_resource: StateResource = StateResource.new()
	assert_false(state_resource.is_owned(), "State resource already owned immediately after being created")

	var state_resource_manager: StateResourceManager = create_state_resource_manager(
		state_machine_dummy_target.get_path(),
		state_resource,
	)
	add_child(state_resource_manager)
	assert_true(state_resource.is_owned(), "State resource not owned after state resource manager added")

	assert_eq(state_resource.get_state_machine(), state_machine_dummy_target.get_path(), "State machine reference not set in state resource")
	assert_eq(state_resource.get_current_state(), StringName(), "State value not empty before entering first state")

	for state in states:
		Signals.emit_state_entered(state_machine_dummy_emitting, StringName(state), {})
		await wait_for_process_frame()
		var expected_state: StringName = state if is_correct_state_machine_emitting else StringName()
		assert_eq(state_resource.get_current_state(), StringName(expected_state))

		Signals.emit_state_exited(state_machine_dummy_emitting, StringName(state), {})
		await wait_for_process_frame()
		assert_eq(state_resource.get_current_state(), StringName())

	state_resource_manager.free()

	assert_false(state_resource.is_owned(), "State resource still onwed after node was deleted")

	state_machine_dummy_target.free()
	if is_instance_valid(state_machine_dummy_emitting):
		state_machine_dummy_emitting.free()


func create_state_resource_manager(state_machine_path: NodePath, state_resource: StateResource) -> StateResourceManager:
	var state_resource_manager_scene: PackedScene = load_scene("state_resource_manager.tscn")
	var state_resource_manager: StateResourceManager = state_resource_manager_scene.instantiate() as StateResourceManager
	assert(state_resource_manager != null, Errors.NULL_NODE)

	state_resource_manager._state_machine = state_machine_path
	state_resource_manager._state_resource = state_resource

	return state_resource_manager
