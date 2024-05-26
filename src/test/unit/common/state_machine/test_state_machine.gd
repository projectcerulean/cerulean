# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const N_STATES: int = 5
const I_DEFAULT_INITIAL_STATE: int = 2


func before_each() -> void:
	super.before_each()
	watch_signals(Signals)


func test_state_machine_initial_state() -> void:
	var state_machine: StateMachine = await create_state_machine(I_DEFAULT_INITIAL_STATE)
	await wait_for_process_frame()
	verify_initial_state(state_machine, I_DEFAULT_INITIAL_STATE)
	state_machine.free()


func test_state_machine_request_state_change() -> void:
	var state_machine: StateMachine = await create_state_machine(I_DEFAULT_INITIAL_STATE)
	verify_initial_state(state_machine, I_DEFAULT_INITIAL_STATE)

	var i_new_state: int = 4
	var new_state_name: StringName = state_machine.get_child(i_new_state).name
	var data_dict: Dictionary = {"some key": "some value"}
	state_machine.transition_to_state(new_state_name, data_dict)
	await wait_for_process_frame()

	verify_state_change(state_machine, I_DEFAULT_INITIAL_STATE, i_new_state, data_dict)

	state_machine.free()


func test_state_machine_request_state_change_next() -> void:
	var state_machine: StateMachine = await create_state_machine(I_DEFAULT_INITIAL_STATE)
	verify_initial_state(state_machine, I_DEFAULT_INITIAL_STATE)

	var data_dict: Dictionary = {"some key": "some value"}
	state_machine.transition_to_next_state(data_dict)
	await wait_for_process_frame()

	verify_state_change(state_machine, I_DEFAULT_INITIAL_STATE, I_DEFAULT_INITIAL_STATE + 1, data_dict)

	state_machine.free()


func test_state_machine_request_state_change_next_wrap() -> void:
	var i_initial_state: int = N_STATES - 1
	var state_machine: StateMachine = await create_state_machine(i_initial_state)
	verify_initial_state(state_machine, i_initial_state)

	var data_dict: Dictionary = {"some key": "some value"}
	state_machine.transition_to_next_state(data_dict)
	await wait_for_process_frame()

	verify_state_change(state_machine, i_initial_state, 0, data_dict)

	state_machine.free()


func test_state_machine_get_state_transition_from_state_transition_frame_process() -> void:
	var i_new_state: int = 4
	var state_machine: StateMachine = await create_state_machine(I_DEFAULT_INITIAL_STATE, i_new_state)
	await wait_for_process_frame()

	verify_state_change(state_machine, I_DEFAULT_INITIAL_STATE, i_new_state, {})

	state_machine.free()


func test_state_machine_get_state_transition_from_state_transition_frame_physics_process() -> void:
	var i_new_state: int = 4
	var state_machine: StateMachine = await create_state_machine(
		I_DEFAULT_INITIAL_STATE,
		i_new_state,
		StateMachine.TRANSITION_FRAME.PHYSICS_PROCESS,
	)
	await wait_for_physics_frame()

	verify_state_change(state_machine, I_DEFAULT_INITIAL_STATE, i_new_state, {})

	state_machine.free()


func test_state_machine_persistent_data() -> void:
	var i_new_state: int = 4
	var persistent_data_resource: PersistentDataResource = PersistentDataResource.new()

	var state_machine: StateMachine = await create_state_machine(
		I_DEFAULT_INITIAL_STATE,
		-1,
		StateMachine.TRANSITION_FRAME.PROCESS,
		persistent_data_resource,
	)
	verify_initial_state(state_machine, I_DEFAULT_INITIAL_STATE)

	var new_state_name: StringName = state_machine.get_child(i_new_state).name
	var data_dict: Dictionary = {"some key": "some value"}
	state_machine.transition_to_state(new_state_name, data_dict)
	await wait_for_process_frame()
	verify_state_change(state_machine, I_DEFAULT_INITIAL_STATE, i_new_state, data_dict)

	state_machine.free()

	clear_signal_watcher()
	watch_signals(Signals)

	state_machine = await create_state_machine(
		I_DEFAULT_INITIAL_STATE,
		-1,
		StateMachine.TRANSITION_FRAME.PROCESS,
		persistent_data_resource,
	)
	verify_initial_state(state_machine, i_new_state)

	state_machine.free()


func create_state_machine(
		i_initial_state: int,
		i_next_state: int = -1,
		transition_frame: StateMachine.TRANSITION_FRAME = StateMachine.TRANSITION_FRAME.PROCESS,
		persistent_data_resource: PersistentDataResource = null,
	) -> StateMachine:
	var state_machine_scene: PackedScene = load_scene("state_machine.tscn")
	var state_machine: StateMachine = state_machine_scene.instantiate() as StateMachine
	assert(state_machine != null, Errors.NULL_NODE)

	var state_names: PackedStringArray = []
	state_names.resize(N_STATES)
	for i in range(N_STATES):
		state_names[i] = "State_" + str(i)

	var transition: StringName = StringName()
	if i_next_state >= 0:
		transition = StringName(state_names[i_next_state])

	var state_script: Script = load_script("state.gd")
	var state_script_doubled: Script = double(state_script, DOUBLE_STRATEGY.SCRIPT_ONLY)
	stub(state_script_doubled, 'enter').to_do_nothing()
	stub(state_script_doubled, 'exit').to_do_nothing()
	stub(state_script_doubled, 'process').to_do_nothing()
	stub(state_script_doubled, 'physics_process').to_do_nothing()
	stub(state_script_doubled, 'get_transition').to_return(transition)

	var initial_state: Node = null
	for i in range(N_STATES):
		var state: Node = Node.new()
		state.name = StringName(state_names[i])
		state.set_script(state_script_doubled)
		state_machine.add_child(state, true)
		if i == i_initial_state:
			initial_state = state

	assert(initial_state != null, Errors.NULL_NODE)
	state_machine.initial_state = initial_state
	state_machine.persistent_data_resource = persistent_data_resource
	state_machine.transition_frame = transition_frame

	add_child(state_machine)

	if state_machine.transition_frame == StateMachine.TRANSITION_FRAME.PROCESS:
		state_machine.set_physics_process(false)
	elif state_machine.transition_frame == StateMachine.TRANSITION_FRAME.PHYSICS_PROCESS:
		state_machine.set_process(false)
	else:
		fail_test("Invalid physics frame parameter")

	await wait_for_process_frame()

	return state_machine


func verify_initial_state(state_machine: StateMachine, i_initial_state: int) -> void:
	verify_method_called_for_states(state_machine, [], "exit")
	verify_method_called_for_states(state_machine, [i_initial_state], "enter")
	if state_machine.is_processing():
		verify_method_called_for_states(state_machine, [i_initial_state], "process")
	if state_machine.is_physics_processing():
		verify_method_called_for_states(state_machine, [i_initial_state], "physics_process")

	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), 0, "Expected no state_exited signals after instatiating state machine")
	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), 1, "Expected exactly one state_entered signal after instatiating state machine")
	assert_signal_emitted_with_parameters(Signals, Signals.state_entered.get_name(), [
		state_machine.get_path(),
		state_machine.get_child(i_initial_state).name,
		{
			&"NEW_STATE": state_machine.get_child(i_initial_state).name,
			&"OLD_STATE": StringName(),
		},
	])


func verify_state_change(state_machine: StateMachine, i_old_state: int, i_new_state: int, data_dict: Dictionary) -> void:
	verify_method_called_for_states(state_machine, [i_old_state], "exit")
	verify_method_called_for_states(state_machine, [i_old_state, i_new_state], "enter")
	if state_machine.is_processing():
		verify_method_called_for_states(state_machine, [i_old_state, i_new_state], "process")
	if state_machine.is_physics_processing():
		verify_method_called_for_states(state_machine, [i_old_state, i_new_state], "physics_process")

	var data_dict_merged: Dictionary = data_dict.duplicate()
	data_dict_merged.merge({
		&"NEW_STATE": state_machine.get_child(i_new_state).name,
		&"OLD_STATE": state_machine.get_child(i_old_state).name,
	})

	assert_signal_emit_count(Signals, Signals.state_exited.get_name(), 1, "Expected exactly one state_exited signal after changing state once")
	assert_signal_emitted_with_parameters(Signals, Signals.state_exited.get_name(), [
		state_machine.get_path(),
		state_machine.get_child(i_old_state).name,
		data_dict_merged,
	])

	assert_signal_emit_count(Signals, Signals.state_entered.get_name(), 2, "Expected exactly two state_entered signals after changing state once")
	assert_signal_emitted_with_parameters(Signals, Signals.state_entered.get_name(), [
		state_machine.get_path(),
		state_machine.get_child(i_new_state).name,
		data_dict_merged,
	])


func verify_method_called_for_states(state_machine: StateMachine, i_states: PackedInt64Array, method_name: String) -> void:
	for i in range(N_STATES):
		if i in i_states:
			assert_called(state_machine.get_child(i), method_name)
		else:
			assert_not_called(state_machine.get_child(i), method_name)
