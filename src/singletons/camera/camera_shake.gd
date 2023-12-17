# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
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


func _process(_delta: float) -> void:
	var offset_total: Vector2 = Vector2.ZERO
	for offset in shake_offsets.values():
		offset_total += offset
	camera.h_offset = offset_total.x
	camera.v_offset = offset_total.y


func _on_request_screen_shake(sender: NodePath, total_duration: float, shake_frequency: float, amplitude: float) -> void:
	shake_start(sender, total_duration, shake_frequency, amplitude)


func _on_scene_changed(_scene: NodePath) -> void:
	for sender in shake_duration_timers.keys():
		shake_stop(sender)


func shake_start(sender: NodePath, total_duration: float, shake_frequency: float, amplitude: float) -> void:
	shake_stop(sender)

	var timer: Timer = Timer.new()
	add_child(timer)
	shake_duration_timers[sender] = timer
	timer.wait_time = total_duration
	timer.one_shot = true
	timer.timeout.connect(func(): on_timer_timeout(sender))
	timer.start()

	shake(sender, 1.0 / shake_frequency, amplitude)


func shake_stop(sender: NodePath) -> void:
	if sender in shake_duration_timers:
		var timer_old: Timer = shake_duration_timers.get(sender) as Timer
		shake_duration_timers.erase(sender)
		timer_old.queue_free()

		var tween_old: Tween = shake_tweens.get(sender) as Tween
		shake_tweens.erase(sender)
		tween_old.kill()

		shake_offsets.erase(sender)


func shake(sender: NodePath, duration: float, amplitude: float) -> void:
	shake_offsets[sender] = Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))

	var tween: Tween = create_tween()
	shake_tweens[sender] = tween
	tween.set_trans(tween_trans)
	tween.set_ease(tween_ease)
	tween.tween_method(func(offset: Vector2): set_shake_offset(sender, offset), shake_offsets[sender], Vector2.ZERO, duration)
	tween.tween_callback(func(): on_tween_finished(sender, duration, amplitude))


func on_timer_timeout(sender: NodePath) -> void:
	shake_stop(sender)


func on_tween_finished(sender: NodePath, duration: float, amplitude: float) -> void:
	shake(sender, duration, amplitude)


func set_shake_offset(sender: NodePath, offset: Vector2) -> void:
	shake_offsets[sender] = offset
