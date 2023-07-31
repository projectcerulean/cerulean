# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var n_sfx_channels: int = 64
@export var bus_name: StringName = &"Sfx"

var i_current_player = 0


func _ready() -> void:
	Signals.request_sfx_play.connect(self._on_request_sfx_play)
	Signals.scene_changed.connect(self._on_scene_changed)
	for i in range(n_sfx_channels):
		var audio_stream_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		audio_stream_player.bus = bus_name
		assert(audio_stream_player.bus == bus_name, Errors.INVALID_AUDIO_BUS)
		add_child(audio_stream_player)

	assert(get_child_count() == n_sfx_channels)
	for child in get_children():
		assert(child as AudioStreamPlayer3D != null, Errors.CONSISTENCY_ERROR)


func _on_request_sfx_play(_sender: NodePath, sfx_resource: SfxResource, position: Vector3) -> void:
	var audio_stream_player: AudioStreamPlayer3D = get_child(i_current_player) as AudioStreamPlayer3D
	audio_stream_player.stop()
	audio_stream_player.stream = sfx_resource.stream_samples[randi() % sfx_resource.stream_samples.size()]
	audio_stream_player.volume_db = sfx_resource.volume_db
	audio_stream_player.pitch_scale = sfx_resource.pitch_scale
	audio_stream_player.global_position = position
	audio_stream_player.play()
	i_current_player = (i_current_player + 1) % n_sfx_channels


func _on_scene_changed(_sender: NodePath) -> void:
	for _audio_stream_player in get_children():
		var audio_stream_player: AudioStreamPlayer3D = _audio_stream_player as AudioStreamPlayer3D
		audio_stream_player.stop()
		audio_stream_player.stream = null
