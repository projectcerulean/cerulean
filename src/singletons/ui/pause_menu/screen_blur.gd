# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends ColorRect

@export var tween_duration: float = 0.1
@export var game_state_resource: StateResource

@onready var shader_material: ShaderMaterial = material as ShaderMaterial
@onready var blur_strength_max: float = shader_material.get_shader_parameter("blur_strength")

var blur_strength: float = 0.0
var tween: Tween


func _ready() -> void:
	Signals.state_entered.connect(_on_state_entered)
	Signals.state_exited.connect(_on_state_exited)
	assert(game_state_resource != null, Errors.NULL_RESOURCE)
	shader_material.set_shader_parameter("blur_strength", 0.0)
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
		tween.tween_property(shader_material, "shader_parameter/blur_strength", blur_strength_max, tween_duration)


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
		tween.tween_property(shader_material, "shader_parameter/blur_strength", 0.0, tween_duration)
		tween.tween_callback(hide)
