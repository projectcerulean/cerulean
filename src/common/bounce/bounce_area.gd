# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BounceArea
extends Area3D

signal body_bounced

@export var bounce_min_speed: float = 5.0
@export var bounce_elasticity: float = 0.75

func on_body_bounced():
	body_bounced.emit()
