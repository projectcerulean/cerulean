# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

signal area_area_entered
signal area_area_exited
signal area_body_entered
signal area_body_exited
signal bgm_area_entered
signal bgm_area_exited
signal bgm_changed
signal debug_write
signal interaction_highlight_set
signal mouse_entered_control
signal request_body_bounce
signal request_dialogue_start
signal request_dialogue_finish
signal request_game_pause
signal request_game_quit
signal request_game_unpause
signal request_interaction
signal request_interaction_highlight
signal request_interaction_unhighlight
signal request_resource_load
signal request_scene_change
signal request_scene_transition_start
signal request_scene_transition_finish
signal request_screen_shake
signal request_setting_update
signal request_settings_save
signal request_sfx_play
signal request_sfx_play_non_diegetic
signal request_state_change
signal request_state_change_next
signal resource_load_completed
signal scene_changed
signal setting_updated
signal state_entered
signal state_exited
signal visualize_vector2
signal visualize_vector3
signal water_entered
signal water_exited


# Assert that all the signals above have a corresponding emission function below
func _ready() -> void:
	var node: Node = Node.new()
	var default_signals: Array[String] = []
	var default_methods: Array[String] = []
	for s in node.get_signal_list():
		default_signals.append(s["name"])
	for m in node.get_method_list():
		default_methods.append(m["name"])
	node.queue_free()

	var signals: Array[String] = []
	var methods: Array[String] = []
	for s in get_signal_list():
		signals.append(s["name"])
	for m in get_method_list():
		methods.append(m["name"])

	for signal_name in signals:
		if signal_name not in default_signals:
			assert(("emit_" + signal_name) in methods, Errors.CONSISTENCY_ERROR)

	for method_name in methods:
		if method_name not in default_methods and method_name.begins_with("emit_"):
			assert((method_name.trim_prefix("emit_")) in signals, Errors.CONSISTENCY_ERROR)


# Helper function for emitting signals
func emit(sig: Signal, args: Array) -> void:
	var signal_name: String = sig.get_name()
	#debug_write.emit(args[0], str(signal_name, ", ", args.slice(1, args.size())))
	callv(&"call_deferred", [&"emit_signal", signal_name] + args)


# Public signal emission functions
func emit_area_area_entered(sender: Area3D, area: Area3D) -> void: emit(area_area_entered, [sender, area])
func emit_area_area_exited(sender: Area3D, area: Area3D) -> void: emit(area_area_exited, [sender, area])
func emit_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void: emit(area_body_entered, [sender, body])
func emit_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void: emit(area_body_exited, [sender, body])
func emit_bgm_area_entered(sender: Area3D, bgm: StringName) -> void: emit(bgm_area_entered, [sender, bgm])
func emit_bgm_area_exited(sender: Area3D) -> void: emit(bgm_area_exited, [sender])
func emit_bgm_changed(sender: Node, bgm: StringName) -> void: emit(bgm_changed, [sender, bgm])
func emit_debug_write(sender: Node, variant: Variant) -> void: emit(debug_write, [sender, variant])
func emit_interaction_highlight_set(sender: Node, target: Node3D) -> void: emit(interaction_highlight_set, [sender, target])
func emit_mouse_entered_control(sender: Control) -> void: emit(mouse_entered_control, [sender])
func emit_request_body_bounce(sender: Node, body: Node3D, target_velocity: Vector3, elasticy: float) -> void: emit(request_body_bounce, [sender, body, target_velocity, elasticy])
func emit_request_dialogue_start(sender: Node3D, dialogue_resource: DialogueResource) -> void: emit(request_dialogue_start, [sender, dialogue_resource])
func emit_request_dialogue_finish(sender: Node) -> void: emit(request_dialogue_finish, [sender])
func emit_request_game_pause(sender: Node) -> void: emit(request_game_pause, [sender])
func emit_request_game_quit(sender: Node) -> void: emit(request_game_quit, [sender])
func emit_request_game_unpause(sender: Node) -> void: emit(request_game_unpause, [sender])
func emit_request_interaction(sender: Node) -> void: emit(request_interaction, [sender])
func emit_request_interaction_highlight(sender: Node3D) -> void: emit(request_interaction_highlight, [sender])
func emit_request_interaction_unhighlight(sender: Node3D) -> void: emit(request_interaction_unhighlight, [sender])
func emit_request_resource_load(sender: Node, resource_path: StringName) -> void: emit(request_resource_load, [sender, resource_path])
func emit_request_scene_change(sender: Node, scene_path: String) -> void: emit(request_scene_change, [sender, scene_path])
func emit_request_scene_transition_start(sender: Node, scene_path: String, spawn_point_id: int, color: Color, duration: float) -> void: emit(request_scene_transition_start, [sender, scene_path, spawn_point_id, color, duration])
func emit_request_scene_transition_finish(sender: Node) -> void: emit(request_scene_transition_finish, [sender])
func emit_request_screen_shake(sender: Node, total_duration: float, frequency: float, amplitude: float) -> void: emit(request_screen_shake, [sender, total_duration, frequency, amplitude])
func emit_request_setting_update(sender: Node, key: StringName, value_index: int) -> void: emit(request_setting_update, [sender, key, value_index])
func emit_request_settings_save(sender: Node) -> void: emit(request_settings_save, [sender])
func emit_request_sfx_play(sender: Node, sfx_resource: SfxResource, position: Vector3) -> void: emit(request_sfx_play, [sender, sfx_resource, position])
func emit_request_sfx_play_non_diegetic(sender: Node, sfx_resource: SfxResource) -> void: emit(request_sfx_play_non_diegetic, [sender, sfx_resource])
func emit_request_state_change(sender: Node, state_machine: Node, state: StringName, data: Dictionary = {}) -> void: emit(request_state_change, [sender, state_machine, state, data])
func emit_request_state_change_next(sender: Node, state_machine: Node, data: Dictionary = {}) -> void: emit(request_state_change_next, [sender, state_machine, data])
func emit_resource_load_completed(sender: Node, resource_path: StringName, resource: Resource) -> void: emit(resource_load_completed, [sender, resource_path, resource])
func emit_scene_changed(sender: Node) -> void: emit(scene_changed, [sender])
func emit_setting_updated(sender: Node, key: StringName) -> void: emit(setting_updated, [sender, key])
func emit_state_entered(sender: Node, state: StringName, data: Dictionary) -> void: emit(state_entered, [sender, state, data])
func emit_state_exited(sender: Node, state: StringName, data: Dictionary) -> void: emit(state_exited, [sender, state, data])
func emit_visualize_vector2(sender: Node, vector: Vector2) -> void: emit(visualize_vector2, [sender, vector])
func emit_visualize_vector3(sender: Node, from: Vector3, to: Vector3) -> void: emit(visualize_vector3, [sender, from, to])
func emit_water_entered(sender: Area3D) -> void: emit(water_entered, [sender])
func emit_water_exited(sender: Area3D) -> void: emit(water_exited, [sender])
