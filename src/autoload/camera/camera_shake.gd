# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Loosely based on "How to Screen Shake in Godot 3.0" by Game Endeavor, https://www.youtube.com/watch?v=_DAvzzJMko8
extends Node

@export var camera: Camera3D
@export var tween_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var tween_ease: Tween.EaseType = Tween.EASE_IN_OUT

var shake_duration_timers: Dictionary  # NodePath -> Timer
var shake_offsets: Dictionary  # NodePath -> Vector2
var shake_tweens: Dictionary  # NodePath -> Tween


func _ready() -> void:
	Signals.request_screen_shake.connect(_on_request_screen_shake)
	Signals.scene_changed.connect(_on_scene_changed)
	assert(camera != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	var offset_total: Vector2 = Vector2.ZERO
	for offset in shake_offsets.values():
		offset_total += offset
	camera.h_offset = offset_total.x
	camera.v_offset = offset_total.y


func _on_request_screen_shake(sender: Node, total_duration: float, shake_frequency: float, amplitude: float) -> void:
	# Use the node path as the key, not the node itself, to prevent issues if the node is freed.
	shake_start(sender.get_path(), total_duration, shake_frequency, amplitude)


func _on_scene_changed(scene: Node) -> void:
	for sender in shake_duration_timers.keys():
		shake_stop(sender)


func shake_start(senderPath: NodePath, total_duration: float, shake_frequency: float, amplitude: float) -> void:
	shake_stop(senderPath)

	var timer: Timer = Timer.new()
	add_child(timer)
	shake_duration_timers[senderPath] = timer
	timer.wait_time = total_duration
	timer.one_shot = true
	timer.timeout.connect(func(): on_timer_timeout(senderPath))
	timer.start()

	shake(senderPath, 1.0 / shake_frequency, amplitude)


func shake_stop(senderPath: NodePath) -> void:
	if senderPath in shake_duration_timers:
		var timer_old: Timer = shake_duration_timers.get(senderPath) as Timer
		shake_duration_timers.erase(senderPath)
		timer_old.queue_free()

		var tween_old: Tween = shake_tweens.get(senderPath) as Tween
		shake_tweens.erase(senderPath)
		tween_old.kill()

		shake_offsets.erase(senderPath)


func shake(senderPath: NodePath, duration: float, amplitude: float) -> void:
	shake_offsets[senderPath] = Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))

	var tween: Tween = create_tween()
	shake_tweens[senderPath] = tween
	tween.set_trans(tween_trans)
	tween.set_ease(tween_ease)
	tween.tween_method(func(offset: Vector2): set_shake_offset(senderPath, offset), shake_offsets[senderPath], Vector2.ZERO, duration)
	tween.tween_callback(func(): on_tween_finished(senderPath, duration, amplitude))


func on_timer_timeout(senderPath: NodePath) -> void:
	shake_stop(senderPath)


func on_tween_finished(senderPath: NodePath, duration: float, amplitude: float) -> void:
	shake(senderPath, duration, amplitude)


func set_shake_offset(senderPath: NodePath, offset: Vector2) -> void:
	shake_offsets[senderPath] = offset
