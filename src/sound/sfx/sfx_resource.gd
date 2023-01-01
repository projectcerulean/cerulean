# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name SfxResource
extends Resource

@export var stream_samples: Array[AudioStreamWAV]
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
