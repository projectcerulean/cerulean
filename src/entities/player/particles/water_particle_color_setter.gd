# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ParticleColorSetter


func get_color() -> Color:
	return environment_resource.value.water_color_foam
