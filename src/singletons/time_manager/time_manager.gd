# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var time_resource: FloatResource
@export var time_resource_dialogue: FloatResource
@export var time_resource_gameplay: FloatResource
@export var time_resource_loading_screen: FloatResource
@export var time_resource_pause: FloatResource
@export var time_resource_scene_transition: FloatResource
@export var game_state_resource: StateResource


func _ready() -> void:
	assert(time_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_dialogue != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)
	assert(time_resource_pause != null, Errors.NULL_RESOURCE)
	time_resource.claim_ownership(self)
	time_resource_dialogue.claim_ownership(self)
	time_resource_loading_screen.claim_ownership(self)
	time_resource_gameplay.claim_ownership(self)
	time_resource_pause.claim_ownership(self)
	time_resource_scene_transition.claim_ownership(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		time_resource.release_ownership(self)
		time_resource_dialogue.release_ownership(self)
		time_resource_gameplay.release_ownership(self)
		time_resource_loading_screen.release_ownership(self)
		time_resource_pause.release_ownership(self)
		time_resource_scene_transition.release_ownership(self)


func _process(delta: float) -> void:
	time_resource.set_value(self, time_resource.get_value() + delta)

	match game_state_resource.get_current_state():
		GameStates.DIALOGUE:
			time_resource_dialogue.set_value(self, time_resource_dialogue.get_value() + delta)
		GameStates.GAMEPLAY:
			time_resource_gameplay.set_value(self, time_resource_gameplay.get_value() + delta)
		GameStates.LOADING_SCREEN:
			time_resource_loading_screen.set_value(self, time_resource_loading_screen.get_value() + delta)
		GameStates.PAUSE:
			time_resource_pause.set_value(self, time_resource_pause.get_value() + delta)
		GameStates.SCENE_TRANSITION:
			time_resource_scene_transition.set_value(self, time_resource_scene_transition.get_value() + delta)
