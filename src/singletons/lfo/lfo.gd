# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

const seconds_per_minute: float = 60.0

@export var bpm_default: float = 90.0
@export var lfo_value_fourth_resource: FloatResource

@onready var bpm: float = bpm_default


func _enter_tree() -> void:
	assert(lfo_value_fourth_resource != null, Errors.NULL_RESOURCE)
	lfo_value_fourth_resource.claim_ownership(self)


func _exit_tree() -> void:
	lfo_value_fourth_resource.release_ownership(self)


func _ready() -> void:
	Signals.bgm_changed.connect(self._on_bgm_changed)


func _process(_delta: float) -> void:
	# TODO: sync with bgm better
	var angle: float = Time.get_unix_time_from_system() * (TAU * bpm / seconds_per_minute)
	lfo_value_fourth_resource.set_value(self, sin(0.25 * angle))


func _on_bgm_changed(_sender: NodePath, bgm_new: StringName) -> void:
	bpm = BgmIndex.BGM_INDEX[bgm_new][BgmIndex.BGM_BPM] if bgm_new != null and bgm_new != StringName() else bpm_default
