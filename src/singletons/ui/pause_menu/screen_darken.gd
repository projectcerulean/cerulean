# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var tween_duration: float = 0.1
@export var game_state_resource: StateResource

var tween: Tween

@onready var color_max: Color = color
@onready var color_min: Color = Color(color_max.r, color_max.g, color_max.g, 0.0)


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)
	Signals.state_exited.connect(_on_state_exited)
	assert(game_state_resource as StateResource != null, Errors.NULL_RESOURCE)
	color = color_min
	hide()


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		game_state_resource.is_owned()
		and sender == game_state_resource.get_state_machine()
		and state == GameStates.PAUSE
	):
		show()
		if tween != null:
				tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "color", color_max, tween_duration)


func _on_state_exited(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		game_state_resource.is_owned()
		and sender == game_state_resource.get_state_machine()
		and state == GameStates.PAUSE
	):
		if tween != null:
				tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "color", color_min, tween_duration)
		tween.tween_callback(hide)
