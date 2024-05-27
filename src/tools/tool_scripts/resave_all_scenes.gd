# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
extends EditorScript


func _run() -> void:
	for file: String in list_all_files():
		if file.ends_with(".tscn"):
			EditorInterface.open_scene_from_path(file)
			EditorInterface.reload_scene_from_path(file)
			EditorInterface.save_scene()


func list_all_files(directory: String = "res://", files: PackedStringArray = PackedStringArray()) -> PackedStringArray:
	var dirAccess: DirAccess = DirAccess.open(directory)
	for file: String in dirAccess.get_files():
		files.append(directory + "/" + file)
	for dir: String in dirAccess.get_directories():
		list_all_files(directory + "/" + dir, files)
	return files
