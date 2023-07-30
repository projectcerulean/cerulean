# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends GutTest

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
	var state_machine_dummy_emitting: Node = state_machine_dummy_target
	if not is_correct_state_machine_emitting:
		state_machine_dummy_emitting = Node.new()

	var state_resource: StateResource = StateResource.new()
	var state_resource_manager: StateResourceManager = create_state_resource_manager(
		state_machine_dummy_target,
		state_resource,
	)
	assert_eq(state_resource.state_machine, null)
	add_child(state_resource_manager)

	assert_eq(state_resource.current_state, StringName())
	assert_eq(state_resource.state_machine, state_machine_dummy_target)

	for state in states:
		Signals.emit_state_entered(state_machine_dummy_emitting, StringName(state), {})
		await TestUtils.wait_for_process_frame(self)
		var expected_state: StringName = state if is_correct_state_machine_emitting else StringName()
		assert_eq(state_resource.current_state, StringName(expected_state))

		Signals.emit_state_exited(state_machine_dummy_emitting, StringName(state), {})
		await TestUtils.wait_for_process_frame(self)
		assert_eq(state_resource.current_state, StringName())

	state_resource_manager.free()

	assert_eq(state_resource.current_state, StringName())
	assert_eq(state_resource.state_machine, null)

	state_machine_dummy_target.free()
	if is_instance_valid(state_machine_dummy_emitting):
		state_machine_dummy_emitting.free()


func create_state_resource_manager(state_machine: Node, state_resource: StateResource) -> StateResourceManager:
	var state_resource_manager_scene: PackedScene = TestUtils.load_scene(self, "state_resource_manager.tscn")
	var state_resource_manager: StateResourceManager = state_resource_manager_scene.instantiate() as StateResourceManager
	assert(state_resource_manager != null)

	state_resource_manager.state_machine = state_machine
	state_resource_manager._state_resource = state_resource

	return state_resource_manager
