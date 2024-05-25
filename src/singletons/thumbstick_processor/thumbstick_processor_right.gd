# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var thumbstick_resource_right: Vector2Resource

@onready var gamepad_stick_processor: GamepadStickProcessor = GamepadStickProcessor.new(
	InputActions.RIGHT_STICK_UP,
	InputActions.RIGHT_STICK_DOWN,
	InputActions.RIGHT_STICK_LEFT,
	InputActions.RIGHT_STICK_RIGHT,
)
@onready var mouse_thumbstick_simulator: MouseThumbstickSimulator = MouseThumbstickSimulator.new()


func _ready() -> void:
	assert(thumbstick_resource_right != null, Errors.NULL_RESOURCE)
	thumbstick_resource_right.claim_ownership(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		thumbstick_resource_right.release_ownership(self)


func _input(event: InputEvent) -> void:
	mouse_thumbstick_simulator.input(event)


func _process(_delta: float) -> void:
	var stick_input: Vector2 = gamepad_stick_processor.process_input()
	var mouse_input: Vector2 = mouse_thumbstick_simulator.process_input()
	thumbstick_resource_right.set_value(
		self,
		stick_input if stick_input.length_squared() > mouse_input.length_squared() else mouse_input,
	)
