# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Label

@export var developer_mode_resource: BoolResource
@export var git_folder: String = "res://.git/"
@export var n_git_hash_characters_to_show: int = 8

const git_hash_length: int = 40


func _ready() -> void:
	assert(developer_mode_resource != null, Errors.NULL_RESOURCE)

	text = (
		Version.NAME + " "
		+ str(Version.MAJOR) + "."
		+ str(Version.MINOR) + "."
		+ str(Version.PATCH) + "-"
		+ Version.STATUS
	)

	var git_hash: String = Version.GIT_HASH
	if git_hash.is_empty():
		if FileAccess.file_exists(git_folder + "HEAD"):
			var head: String = FileAccess.open(git_folder + "HEAD", FileAccess.READ).get_as_text().strip_edges()
			if head.begins_with("ref: "):
				if FileAccess.file_exists(git_folder + head.trim_prefix("ref: ")):
					head = FileAccess.open(git_folder + head.trim_prefix("ref: "), FileAccess.READ).get_as_text().strip_edges()
					if head.length() == git_hash_length and head.is_valid_hex_number():
						git_hash = head
			elif head.length() == git_hash_length and head.is_valid_hex_number():
				git_hash = head
	if not git_hash.is_empty():
		text += "." + git_hash.substr(0, n_git_hash_characters_to_show)

	if developer_mode_resource.is_owned() and developer_mode_resource.get_value():
		text += " [DEVELOPER MODE]"
