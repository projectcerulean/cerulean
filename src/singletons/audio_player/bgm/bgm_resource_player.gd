# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name BgmResourcePlayer
extends Node

const volume_db_min: float = -80.0
const volume_db_max: float = 0.0

@export var tween_duration: float = 5.0

var _bgm_resource_path: String
var _bgm_resource: BgmResource
var _tween: Tween

var volume: float:
	get:
		var value: float = clampf(volume, 0.0, 1.0)
		if is_nan(value):
			return 0.0
		else:
			return value
	set (value):
		assert(not is_nan(value) and not is_inf(value), Errors.INVALID_ARGUMENT)
		volume = clampf(value, 0.0, 1.0)
		for _audio_stream_player: Node in get_children():
			var audio_stream_player: AudioStreamPlayer = _audio_stream_player as AudioStreamPlayer
			audio_stream_player.volume_db = linear_to_db(lerpf(db_to_linear(volume_db_min), db_to_linear(volume_db_max), volume))

@onready var base_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var glide_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var rhythm_player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	Signals.resource_load_completed.connect(_on_resource_load_completed)

	assert(base_player != null, Errors.NULL_NODE)
	assert(glide_player != null, Errors.NULL_NODE)
	assert(rhythm_player != null, Errors.NULL_NODE)

	add_child(base_player)
	add_child(glide_player)
	add_child(rhythm_player)

	base_player.bus = AudioBuses.BGM_BASE
	glide_player.bus = AudioBuses.BGM_GLIDE
	rhythm_player.bus = AudioBuses.BGM_RHYTHM

	volume = 0.0


func load_bgm_resource(bgm_resource_path: String) -> void:
	assert(bgm_resource_path, Errors.INVALID_ARGUMENT)
	assert(not _bgm_resource_path, Errors.INVALID_CONTEXT)
	_bgm_resource_path = bgm_resource_path
	Signals.emit_request_resource_load(self, _bgm_resource_path)


func _on_resource_load_completed(_sender: NodePath, resource_path: String, resource: Resource) -> void:
	if resource_path != _bgm_resource_path:
		return

	_bgm_resource = resource as BgmResource
	assert(_bgm_resource != null, Errors.NULL_RESOURCE)

	base_player.stream = _bgm_resource.stream_sample_base
	glide_player.stream = _bgm_resource.stream_sample_glide
	rhythm_player.stream = _bgm_resource.stream_sample_rhythm

	assert(base_player.stream != null, Errors.NULL_RESOURCE)
	var start_position: float = randf_range(0.0, base_player.stream.get_length())
	base_player.play()
	base_player.seek(start_position)

	if glide_player.stream != null:
		assert(glide_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)
		glide_player.play()
		glide_player.seek(start_position)
	if rhythm_player.stream != null:
		assert(rhythm_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)
		rhythm_player.play()
		rhythm_player.seek(start_position)

	if _tween != null and _tween.is_valid() and not _tween.is_running():
		_tween.play()


func set_enabled(enabled: bool) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "volume", float(enabled), tween_duration)
	if _bgm_resource == null:
		_tween.pause()
