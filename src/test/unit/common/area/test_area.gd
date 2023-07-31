# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends UnitTest

const AREA_POSITION: Vector3 = Vector3(100.0, 200.0, 300.0)
const N_PHYSICS_FRAMES_TO_WAIT: int = 3

var area: Area
var area_collider: Area3D
var body_collider: RigidBody3D


func before_each() -> void:
	super.before_each()

	watch_signals(Signals)

	var area_scene: PackedScene = load_scene("area.tscn")
	area = area_scene.instantiate() as Area
	assert(area != null, Errors.NULL_NODE)
	add_collision_shape(area)
	add_child_autofree(area)
	area.global_position = AREA_POSITION

	area_collider = Area3D.new()
	add_collision_shape(area_collider)
	add_child_autofree(area_collider)

	body_collider = RigidBody3D.new()
	add_collision_shape(body_collider)
	add_child_autofree(body_collider)


func test_no_collision() -> void:
	await wait_for_physics_frames(N_PHYSICS_FRAMES_TO_WAIT)
	verify_signals_emitted(false, false, false, false)


func test_area_collision() -> void:
	area_collider.global_position = AREA_POSITION
	await wait_for_physics_frames(N_PHYSICS_FRAMES_TO_WAIT)
	verify_signals_emitted(true, false, false, false)

	area_collider.global_position = Vector3()
	await wait_for_physics_frames(N_PHYSICS_FRAMES_TO_WAIT)
	verify_signals_emitted(true, true, false, false)


func test_body_collision() -> void:
	body_collider.global_position = AREA_POSITION
	await wait_for_physics_frames(N_PHYSICS_FRAMES_TO_WAIT)
	verify_signals_emitted(false, false, true, false)

	body_collider.global_position = Vector3()
	await wait_for_physics_frames(N_PHYSICS_FRAMES_TO_WAIT)
	verify_signals_emitted(false, false, true, true)


func add_collision_shape(node: Node3D) -> void:
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	node.add_child(collision_shape)


func verify_signals_emitted(area_entered: bool, area_exited: bool, body_entered: bool, body_exited: bool) -> void:
	assert_signal_emit_count(Signals, Signals.area_area_entered.get_name(), int(area_entered))
	assert_signal_emit_count(Signals, Signals.area_area_exited.get_name(), int(area_exited))
	assert_signal_emit_count(Signals, Signals.area_body_entered.get_name(), int(body_entered))
	assert_signal_emit_count(Signals, Signals.area_body_exited.get_name(), int(body_exited))
