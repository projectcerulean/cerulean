# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
@tool
extends EditorScript


func _run():
	var editor_interface: EditorInterface = get_editor_interface()
	for file in list_all_files():
		if file.ends_with(".tscn"):
			editor_interface.open_scene_from_path(file)
			editor_interface.reload_scene_from_path(file)
			editor_interface.save_scene()


func list_all_files(directory: String = "res://", files: PackedStringArray = PackedStringArray()) -> PackedStringArray:
	var dirAccess: DirAccess = DirAccess.open(directory)
	for file in dirAccess.get_files():
		files.append(directory + "/" + file)
	for dir in dirAccess.get_directories():
		list_all_files(directory + "/" + dir, files)
	return files
