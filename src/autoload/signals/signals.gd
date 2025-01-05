# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

signal area_area_entered
signal area_area_exited
signal area_body_entered
signal area_body_exited
signal bgm_area_entered
signal bgm_area_exited
signal bgm_changed
signal closest_interactable_changed
signal debug_write
signal interaction_performed
signal mouse_entered_control
signal request_camera_shake_impulse
signal request_camera_shake_sustained
signal request_camera_shake_sustained_stop
signal request_dialogue_start
signal request_dialogue_finish
signal request_game_pause
signal request_game_quit
signal request_game_unpause
signal request_loading_screen_start
signal request_resource_load
signal request_scene_change
signal request_scene_transition_start
signal request_scene_transition_finish
signal request_setting_update
signal request_settings_save
signal request_sfx_play
signal request_sfx_play_non_diegetic
signal resource_load_completed
signal scene_changed
signal setting_updated
signal state_entered
signal state_exited
signal visualize_vector2
signal visualize_vector3


# Assert that all the signals above have a corresponding emission function below
func _ready() -> void:
	var node: Node = Node.new()
	var default_signals: PackedStringArray = []
	var default_methods: PackedStringArray = []
	for s: Dictionary in node.get_signal_list():
		@warning_ignore("unsafe_cast")
		default_signals.append(s["name"] as StringName)
	for m: Dictionary in node.get_method_list():
		@warning_ignore("unsafe_cast")
		default_methods.append(m["name"] as StringName)
	node.queue_free()

	var signals: PackedStringArray = []
	var methods: PackedStringArray = []
	for s: Dictionary in get_signal_list():
		@warning_ignore("unsafe_cast")
		signals.append(s["name"] as StringName)
	for m: Dictionary in get_method_list():
		@warning_ignore("unsafe_cast")
		methods.append(m["name"] as StringName)

	for signal_name: StringName in signals:
		if signal_name not in default_signals:
			assert(("emit_" + signal_name) in methods, Errors.CONSISTENCY_ERROR)

	for method_name: StringName in methods:
		if method_name not in default_methods and method_name.begins_with("emit_"):
			assert((method_name.trim_prefix("emit_")) in signals, Errors.CONSISTENCY_ERROR)


# Helper function for emitting signals
func emit(sig: Signal, sender: Node, args: Array) -> void:
	var signal_name: String = sig.get_name()
	assert(sender.is_inside_tree(), Errors.INVALID_ARGUMENT)
	assert(is_same(sender.get_tree(), get_tree()), Errors.INVALID_ARGUMENT)
	var sender_path: NodePath = sender.get_path()
	#debug_write.emit(sender.name, str(signal_name, ", ", args.slice(1, args.size())))
	callv(&"call_deferred", [&"emit_signal", signal_name, sender_path] + args)


# Public signal emission functions
func emit_area_area_entered(sender: Area3D, area: NodePath) -> void: emit(area_area_entered, sender, [area])
func emit_area_area_exited(sender: Area3D, area: NodePath) -> void: emit(area_area_exited, sender, [area])
func emit_area_body_entered(sender: Area3D, body: NodePath) -> void: emit(area_body_entered, sender, [body])
func emit_area_body_exited(sender: Area3D, body: NodePath) -> void: emit(area_body_exited, sender, [body])
func emit_bgm_area_entered(sender: Area3D, bgm: StringName, priority: float) -> void: emit(bgm_area_entered, sender, [bgm, priority])
func emit_bgm_area_exited(sender: Area3D) -> void: emit(bgm_area_exited, sender, [])
func emit_bgm_changed(sender: Node, bgm: StringName) -> void: emit(bgm_changed, sender, [bgm])
func emit_closest_interactable_changed(sender: Node, closest_interactable: NodePath) -> void: emit(closest_interactable_changed, sender, [closest_interactable])
func emit_debug_write(sender: Node, variant: Variant) -> void: emit(debug_write, sender, [variant])
func emit_interaction_performed(sender: Node, closest_interactable: NodePath) -> void: emit(interaction_performed, sender, [closest_interactable])
func emit_mouse_entered_control(sender: Control) -> void: emit(mouse_entered_control, sender, [])
func emit_request_camera_shake_impulse(sender: Node, trauma: float) -> void: emit(request_camera_shake_impulse, sender, [trauma])
func emit_request_camera_shake_sustained(sender: Node, camera_shake_resource: CameraShakeSustainedResource) -> void: emit(request_camera_shake_sustained, sender, [camera_shake_resource])
func emit_request_camera_shake_sustained_stop(sender: Node) -> void: emit(request_camera_shake_sustained_stop, sender, [])
func emit_request_dialogue_start(sender: Node3D, dialogue_resource: DialogueResource) -> void: emit(request_dialogue_start, sender, [dialogue_resource])
func emit_request_dialogue_finish(sender: Node) -> void: emit(request_dialogue_finish, sender, [])
func emit_request_game_pause(sender: Node) -> void: emit(request_game_pause, sender, [])
func emit_request_game_quit(sender: Node) -> void: emit(request_game_quit, sender, [])
func emit_request_game_unpause(sender: Node) -> void: emit(request_game_unpause, sender, [])
func emit_request_loading_screen_start(sender: Node) -> void: emit(request_loading_screen_start, sender, [])
func emit_request_resource_load(sender: Node, resource_path: String) -> void: emit(request_resource_load, sender, [resource_path])
func emit_request_scene_change(sender: Node, scene_path: String, spawn_point_id: int) -> void: emit(request_scene_change, sender, [scene_path, spawn_point_id])
func emit_request_scene_transition_start(sender: Node, scene_path: String, spawn_point_id: int, color: Color, duration: float) -> void: emit(request_scene_transition_start, sender, [scene_path, spawn_point_id, color, duration])
func emit_request_scene_transition_finish(sender: Node) -> void: emit(request_scene_transition_finish, sender, [])
func emit_request_setting_update(sender: Node, key: StringName, value_index: int) -> void: emit(request_setting_update, sender, [key, value_index])
func emit_request_settings_save(sender: Node) -> void: emit(request_settings_save, sender, [])
func emit_request_sfx_play(sender: Node, sfx_resource: SfxResource, position: Vector3) -> void: emit(request_sfx_play, sender, [sfx_resource, position])
func emit_request_sfx_play_non_diegetic(sender: Node, sfx_resource: SfxResource) -> void: emit(request_sfx_play_non_diegetic, sender, [sfx_resource])
func emit_resource_load_completed(sender: Node, resource_path: String, resource: Resource) -> void: emit(resource_load_completed, sender, [resource_path, resource])
func emit_scene_changed(sender: Node) -> void: emit(scene_changed, sender, [])
func emit_setting_updated(sender: Node, key: StringName) -> void: emit(setting_updated, sender, [key])
func emit_state_entered(sender: Node, state: StringName, data: Dictionary) -> void: emit(state_entered, sender, [state, data])
func emit_state_exited(sender: Node, state: StringName, data: Dictionary) -> void: emit(state_exited, sender, [state, data])
func emit_visualize_vector2(sender: Node, vector: Vector2) -> void: emit(visualize_vector2, sender, [vector])
func emit_visualize_vector3(sender: Node, from: Vector3, to: Vector3) -> void: emit(visualize_vector3, sender, [from, to])
