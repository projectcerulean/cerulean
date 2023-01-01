# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends GameState


func enter(data: Dictionary) -> void:
	super.enter(data)
	get_tree().paused = true


func exit(data: Dictionary) -> void:
	super.exit(data)
	get_tree().paused = false
