# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Label

@export var git_folder: String = "res://.git/"
@export var n_git_hash_characters_to_show: int = 8

const git_hash_length: int = 40


func _ready() -> void:
	text = (
		Version.NAME + " "
		+ str(Version.MAJOR) + "."
		+ str(Version.MINOR) + "."
		+ str(Version.PATCH) + "-"
		+ Version.STATUS
	)

	var git_hash: String = Version.GIT_HASH
	if git_hash.is_empty():
		var file: File = File.new()
		if file.file_exists(git_folder + "HEAD"):
			file.open(git_folder + "HEAD", File.READ)
			var head: String = file.get_as_text().strip_edges()
			file.close()
			if head.begins_with("ref: "):
				if file.file_exists(git_folder + head.trim_prefix("ref: ")):
					file.open(git_folder + head.trim_prefix("ref: "), File.READ)
					head = file.get_as_text().strip_edges()
					file.close()
					if head.length() == git_hash_length and head.is_valid_hex_number():
						git_hash = head
			elif head.length() == git_hash_length and head.is_valid_hex_number():
				git_hash = head
	if not git_hash.is_empty():
		text += "." + git_hash.substr(0, n_git_hash_characters_to_show)
