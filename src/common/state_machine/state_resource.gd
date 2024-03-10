# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name StateResource
extends Resource

var state_machine: NodePath = NodePath()
var current_state: StringName = StringName()
