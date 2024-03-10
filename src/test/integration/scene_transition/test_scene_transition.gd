# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends IntegrationTest

const ERROR_INTERVAL: Vector3 = Vector3.ONE * 0.01
const FADE_COLOR: Color = Color.BLACK
const FADE_DURATION: float = 0.1
const SIGNAL_WAIT_TIME: float = 1.0

@onready var player_transform_resource: TransformResource = load("res://src/entities/player/player_transform.tres")
@onready var camera_transform_resource: TransformResource = load("res://src/singletons/camera/camera_transform.tres")
@onready var scene_info_resource: SceneInfoResource = load("res://src/singletons/scene_manager/scene_info_resource.tres")


func get_test_scene_name() -> String:
	return "test_scene_1.tscn"


func test_scene_transition() -> void:
	assert_not_null(player_transform_resource)
	assert_not_null(camera_transform_resource)
	assert_not_null(scene_info_resource)

	var test_scene_paths: PackedStringArray = [
		get_script_dir_path() + "/" + "test_scene_1.tscn",
		get_script_dir_path() + "/" + "test_scene_2.tscn",
	]

	for i in range(3):
		for test_scene_path in test_scene_paths:
			Signals.emit_request_scene_transition_start(self, test_scene_path, i, FADE_COLOR, FADE_DURATION)
			await wait_for_signal(Signals.scene_changed, SIGNAL_WAIT_TIME)
			await wait_for_process_frame()

			# Check scene info
			assert_eq(scene_info_resource.scene_path, test_scene_path, "Incorrect scene path in scene data resource after scene transition to %s, spawn point %s" % [test_scene_path, i])
			assert_eq(scene_info_resource.spawn_point_id, i, "Incorrect spawn point id in scene data resource after scene transition to (%s, %s)" % [test_scene_path, i])

			# Check player position
			var test_scene: Node = get_test_scene()
			var player_global_position: Vector3 = player_transform_resource.value.origin
			assert_ne(player_global_position, Vector3.ZERO, "Player position not set in transform resource after scene transition to %s, spawn point %s" % [test_scene_path, i])
			var closest_spawn_point_to_player: PlayerSpawnPoint = get_closest_child(test_scene, player_global_position) as PlayerSpawnPoint
			assert_not_null(closest_spawn_point_to_player, "Unable to determine player spawn point after scene transition to %s, spawn point %s" % [test_scene_path, i])
			assert_eq(closest_spawn_point_to_player.id, i, "Player created at incorrect spawn point after scene transition to %s, spawn point %s" % [test_scene_path, i])

			# Check player rotation
			var player_rotation_euler: Vector3 = player_transform_resource.value.basis.get_euler()
			assert_ne(player_rotation_euler, Vector3.ZERO, "No player rotation set after scene transition to %s, spawn point %s" % [test_scene_path, i])
			assert_almost_eq(
				player_rotation_euler,
				closest_spawn_point_to_player.basis.get_euler(),
				ERROR_INTERVAL,
				"Incorrect player rotation after scene transition to %s, spawn point %s" % [test_scene_path, i],
			)

			# Check camera rotation
			var camera_global_position: Vector3 = camera_transform_resource.value.origin
			assert_ne(camera_global_position, Vector3.ZERO, "Camera position not set in transform resource after scene transition to %s, spawn point %s" % [test_scene_path, i])
			var camera_vector: Vector3 = player_global_position - camera_global_position
			var camera_vector_planar: Vector3 = Vector3(camera_vector.x, 0.0, camera_vector.z).normalized()
			assert_almost_eq(
				-player_transform_resource.value.basis.z,
				camera_vector_planar,
				ERROR_INTERVAL,
				"Incorrect camera angle after scene transition to %s, spawn point %s" % [test_scene_path, i],
			)


func get_closest_child(parent: Node3D, target_position: Vector3) -> Node3D:
	var least_distance_squared: float = INF
	var closest_child: Node3D = null
	for i in parent.get_child_count():
		var child: Node3D = parent.get_child(i) as Node3D
		assert(child != null, Errors.NULL_NODE)
		var distance_squared: float = child.global_position.distance_squared_to(target_position)
		if distance_squared < least_distance_squared:
			closest_child = child
			least_distance_squared = distance_squared
	return closest_child
