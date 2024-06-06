# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name CameraShakeSustainedResource
extends Resource

@export var trauma_envelope: Curve
@export var trauma_factor: float = 0.1
@export var total_duration: float = 1.0
