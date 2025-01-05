# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const ERROR_INTERVAL: float = 0.001

var process_delta: float


func before_all() -> void:
	super.before_all()
	var physics_ticks_per_second: float = float(Engine.physics_ticks_per_second)
	process_delta = 1.0 / physics_ticks_per_second


func test_proportional_term() -> void:
	var p_gain: float = 3.0
	var current_value: float = 7.0
	var target_value: float = 13.0
	var pid_controller: PidController = PidController.new(p_gain, 0.0, 0.0, 0.0)

	var output: float = pid_controller.update(current_value, target_value, process_delta)
	assert_almost_eq(output, p_gain * (target_value - current_value), ERROR_INTERVAL)


func test_integral_term() -> void:
	var i_gain: float = 3.0
	var current_value: float = 7.0
	var target_value: float = 13.0
	var error_integral_max: float = 100.0
	var pid_controller: PidController = PidController.new(0.0, i_gain, 0.0, error_integral_max)

	for i: int in range(10):
		var output: float = pid_controller.update(current_value, target_value, process_delta)
		assert_almost_eq(output, (i + 1) * i_gain * (target_value - current_value) * process_delta, ERROR_INTERVAL)


func test_integral_term_anti_windup() -> void:
	var i_gain: float = 3.0
	var current_value: float = 7.0
	var target_value: float = 13.0
	var expected_error_integral_per_simulation_step: float = (target_value - current_value) * process_delta
	var n_simulation_steps_to_hit_max_integral: int = 100
	var error_integral_max: float = n_simulation_steps_to_hit_max_integral * expected_error_integral_per_simulation_step
	var pid_controller: PidController = PidController.new(0.0, i_gain, 0.0, error_integral_max)

	var output: float
	for i: int in range(n_simulation_steps_to_hit_max_integral - 1):
		output = pid_controller.update(current_value, target_value, process_delta)
	assert_lt(output, i_gain * error_integral_max)

	# This next timestep the pid controller should exactly hit the max error integral
	output = pid_controller.update(current_value, target_value, process_delta)
	assert_almost_eq(output, i_gain * error_integral_max, ERROR_INTERVAL)

	# Error integral should not increase anymore
	output = pid_controller.update(current_value, target_value, process_delta)
	assert_almost_eq(output, i_gain * error_integral_max, ERROR_INTERVAL)


func test_integral_term_reset() -> void:
	var i_gain: float = 3.0
	var current_value: float = 7.0
	var target_value: float = 13.0
	var error_integral_max: float = 100.0
	var pid_controller: PidController = PidController.new(0.0, i_gain, 0.0, error_integral_max)

	for i: int in range(10):
		var output: float = pid_controller.update(current_value, target_value, process_delta)
		assert_almost_eq(output, (i + 1) * i_gain * (target_value - current_value) * process_delta, ERROR_INTERVAL)

	pid_controller.reset()

	# After reset, the I-term should only include error from the most recent update
	var output_after_reset: float = pid_controller.update(current_value, target_value, process_delta)
	assert_almost_eq(output_after_reset, i_gain * (target_value - current_value) * process_delta, ERROR_INTERVAL)


func test_derivative_term() -> void:
	var d_gain: float = 3.0
	var target_value: float = 29.0
	var values: PackedFloat64Array = [-5.0, -1.0, 0.0, 11.0, 13.0, -17.0, 23.0]
	var pid_controller: PidController = PidController.new(0.0, 0.0, d_gain, 0.0)

	for i: int in range(len(values)):
		var value: float = values[i]
		var output: float = pid_controller.update(value, target_value, process_delta)
		if i == 0:
			assert_almost_eq(output, 0.0, ERROR_INTERVAL)
		else:
			var value_prev: float = values[i - 1]
			assert_almost_eq(output, d_gain * (value_prev - value) / process_delta, ERROR_INTERVAL)


func test_derivative_term_reset() -> void:
	var d_gain: float = 3.0
	var target_value: float = 29.0
	var values: PackedFloat64Array = [-5.0, -1.0, 0.0, 11.0, 13.0, -17.0, 23.0]
	var pid_controller: PidController = PidController.new(0.0, 0.0, d_gain, 0.0)

	for i: int in range(len(values)):
		var value: float = values[i]
		var output: float = pid_controller.update(value, target_value, process_delta)
		if i == 0:
			assert_almost_eq(output, 0.0, ERROR_INTERVAL)
		else:
			var value_prev: float = values[i - 1]
			assert_almost_eq(output, d_gain * (value_prev - value) / process_delta, ERROR_INTERVAL)

	pid_controller.reset()

	# After reset, the P-term for the first update should be zero
	var value_new: float = 15.0
	var output_after_reset: float = pid_controller.update(value_new, target_value, process_delta)
	assert_almost_eq(output_after_reset, 0.0, ERROR_INTERVAL)


func test_rigid_body_steady_state_p_term_only() -> void:
	var simulation_time_seconds: float = 600.0
	var n_simulation_steps: int = int(simulation_time_seconds / process_delta)

	var p_gain: float = 1.0
	var target_position: float = 11.0
	var initial_position: float = 7.0
	var mass: float = 3.0
	var pid_controller: PidController = PidController.new(p_gain, 0.0, 0.0, 0.0)
	var rigid_body: SimulatedRigidBody = SimulatedRigidBody.new(mass, initial_position)

	for i: int in range(n_simulation_steps):
		var force: float = pid_controller.update(rigid_body.position, target_position, process_delta)
		rigid_body.apply_central_force(force)
		rigid_body.simulate_physics_process(process_delta)

	# There should *not* be any steady state
	assert_almost_ne(rigid_body.position, target_position, ERROR_INTERVAL)


func test_rigid_body_steady_state_pd_terms() -> void:
	var simulation_time_seconds: float = 60.0
	var n_simulation_steps: int = int(simulation_time_seconds / process_delta)

	var p_gain: float = 1.0
	var d_gain: float = 1.0
	var pid_controller: PidController = PidController.new(p_gain, 0.0, d_gain, 0.0)

	var initial_position: float = 7.0
	var mass: float = 3.0
	var rigid_body: SimulatedRigidBody = SimulatedRigidBody.new(mass, initial_position)

	var target_position: float = 11.0

	for i: int in range(n_simulation_steps):
		var force: float = pid_controller.update(rigid_body.position, target_position, process_delta)
		rigid_body.apply_central_force(force)
		rigid_body.simulate_physics_process(process_delta)

	# There should be steady state
	assert_almost_eq(rigid_body.position, target_position, ERROR_INTERVAL)


func test_rigid_body_steady_state_pid_terms_constant_gravity() -> void:
	var simulation_time_seconds: float = 120.0
	var n_simulation_steps: int = int(simulation_time_seconds / process_delta)

	var p_gain: float = 1.0
	var i_gain: float = 0.1
	var d_gain: float = 3.0
	var error_integral_max: float = 10_000.0
	var pid_controller: PidController = PidController.new(p_gain, i_gain, d_gain, error_integral_max)

	var initial_position: float = 7.0
	var mass: float = 3.0
	var gravity: float = 3.0
	var rigid_body: SimulatedRigidBody = SimulatedRigidBody.new(mass, initial_position)

	var target_position: float = 11.0

	for i: int in range(n_simulation_steps):
		var force: float = pid_controller.update(rigid_body.position, target_position, process_delta)
		rigid_body.apply_central_force(force)
		rigid_body.apply_central_force(mass * gravity)
		rigid_body.simulate_physics_process(process_delta)

	# There should be steady state, even though there is a constant gravity force on the body
	assert_almost_eq(rigid_body.position, target_position, ERROR_INTERVAL)


func test_rigid_body_steady_state_pd_terms_damping() -> void:
	var simulation_time_seconds: float = 60.0
	var n_simulation_steps: int = int(simulation_time_seconds / process_delta)

	var initial_position: float = 7.0
	var target_position: float = 11.0
	var mass: float = 3.0

	var p_gain: float = 5.0

	var run_simulation: Callable = func(d_gain: float) -> PackedFloat64Array:
		var rigid_body: SimulatedRigidBody = SimulatedRigidBody.new(mass, initial_position)
		var pid_controller: PidController = PidController.new(p_gain, 0.0, d_gain, 0.0)

		var positions: PackedFloat64Array = PackedFloat64Array()
		positions.resize(n_simulation_steps)

		for i: int in range(n_simulation_steps):
			var force: float = pid_controller.update(rigid_body.position, target_position, process_delta)
			rigid_body.apply_central_force(force)
			rigid_body.simulate_physics_process(process_delta)
			positions[i] = rigid_body.position

		return positions

	var d_gain_critical_damping: float = sqrt(4.0 * mass * p_gain)
	var d_gain_overdamped: float = 1.1 * d_gain_critical_damping
	var d_gain_underdamped: float = 0.9 * d_gain_critical_damping

	var positions_critical_damping: PackedFloat64Array = run_simulation.call(d_gain_critical_damping)
	var positions_overdamped: PackedFloat64Array = run_simulation.call(d_gain_overdamped)
	var positions_underdamped: PackedFloat64Array = run_simulation.call(d_gain_underdamped)

	# A critically damped system should not overshoot the target
	var critical_damping_overshoot: bool = false
	for i: int in range(len(positions_critical_damping)):
		if positions_critical_damping[i] > target_position + ERROR_INTERVAL:
			critical_damping_overshoot = true
	assert_false(critical_damping_overshoot)

	# An overdamped system should not overshoot the target
	var overdamped_overshoot: bool = false
	for i: int in range(len(positions_overdamped)):
		if positions_overdamped[i] > target_position + ERROR_INTERVAL:
			overdamped_overshoot = true
	assert_false(overdamped_overshoot)

	# An overdamped system should have higher total error than a critically damped system
	var critical_damping_total_error: float = 0.0
	for i: int in range(len(positions_critical_damping)):
		critical_damping_total_error += absf(positions_critical_damping[i] - target_position)
	var overdamped_total_error: float = 0.0
	for i: int in range(len(positions_overdamped)):
		overdamped_total_error += absf(positions_overdamped[i] - target_position)
	assert_gt(overdamped_total_error, critical_damping_total_error + ERROR_INTERVAL)

	# An underdamped system should overshoot the target
	var underdamped_overshoot: bool = false
	for i: int in range(len(positions_underdamped)):
		if positions_underdamped[i] > target_position + ERROR_INTERVAL:
			underdamped_overshoot = true
	assert_true(underdamped_overshoot)
