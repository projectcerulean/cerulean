# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

const seconds_per_minute: float = 60.0

@export var bpm_default: float = 90.0
@export var _lfo_resource: Resource

@onready var bpm: float = bpm_default
@onready var lfo_resource: LfoResource = _lfo_resource as LfoResource


func _ready() -> void:
	Signals.bgm_changed.connect(self._on_bgm_changed)
	assert(lfo_resource != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	# TODO: sync with bgm better
	var angle: float = Time.get_unix_time_from_system() * (TAU * bpm / seconds_per_minute)

	lfo_resource.value_double = sin(2.0 * angle)
	lfo_resource.value_whole = sin(angle)
	lfo_resource.value_half = sin(0.5 * angle)
	lfo_resource.value_fourth = sin(0.25 * angle)

	lfo_resource.value_double_shifted = cos(2.0 * angle)
	lfo_resource.value_whole_shifted = cos(angle)
	lfo_resource.value_half_shifted = cos(0.5 * angle)
	lfo_resource.value_fourth_shifted = cos(0.25 * angle)


func _on_bgm_changed(_sender: NodePath, bgm_new: StringName) -> void:
	bpm = BgmIndex.BGM_INDEX[bgm_new][BgmIndex.BGM_BPM] if bgm_new != null and bgm_new != StringName() else bpm_default
