# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Scene
extends Node3D


func _ready() -> void:
	if is_same(self, get_tree().current_scene):
		# Handle Godot's 'Run Current Scene' option
		_restart_scene_with_proper_scene_tree_root()
		return

	Signals.emit_scene_changed(self)


func _restart_scene_with_proper_scene_tree_root() -> void:
	var main_scene: PackedScene = load("res://src/main/main.tscn") as PackedScene
	assert(main_scene != null, Errors.NULL_RESOURCE)
	var main_scene_instance: Main = main_scene.instantiate() as Main
	assert(main_scene_instance != null, Errors.NULL_NODE)
	main_scene_instance.scene_default = scene_file_path
	var main_scene_updated: PackedScene = PackedScene.new()
	main_scene_updated.pack(main_scene_instance)
	get_tree().change_scene_to_packed(main_scene_updated)
