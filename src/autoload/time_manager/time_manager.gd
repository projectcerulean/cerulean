# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var _time_resource: Resource
@export var _time_resource_dialogue: Resource
@export var _time_resource_gameplay: Resource
@export var _time_resource_pause: Resource
@export var _time_resource_scene_transition: Resource
@export var _game_state_resource: Resource

@onready var time_resource: FloatResource = _time_resource as FloatResource
@onready var time_resource_dialogue: FloatResource = _time_resource_dialogue as FloatResource
@onready var time_resource_gameplay: FloatResource = _time_resource_gameplay as FloatResource
@onready var time_resource_pause: FloatResource = _time_resource_pause as FloatResource
@onready var time_resource_scene_transition: FloatResource = _time_resource_scene_transition as FloatResource
@onready var game_state_resource: StateResource = _game_state_resource as StateResource


func _ready() -> void:
	assert(time_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_dialogue != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)
	assert(time_resource_pause != null, Errors.NULL_RESOURCE)
	assert(time_resource.value == 0.0, Errors.RESOURCE_BUSY)
	assert(time_resource_dialogue.value == 0.0, Errors.RESOURCE_BUSY)
	assert(time_resource_gameplay.value == 0.0, Errors.RESOURCE_BUSY)
	assert(time_resource_pause.value == 0.0, Errors.RESOURCE_BUSY)


func _process(delta: float) -> void:
	time_resource.value += delta

	match game_state_resource.current_state:
		GameStates.DIALOGUE: time_resource_dialogue.value += delta
		GameStates.GAMEPLAY: time_resource_gameplay.value += delta
		GameStates.PAUSE: time_resource_pause.value += delta
		GameStates.SCENE_TRANSITION: time_resource_scene_transition.value += delta
