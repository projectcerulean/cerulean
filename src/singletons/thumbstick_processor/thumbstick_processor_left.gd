# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var thumbstick_resource_left: Vector2Resource

@onready var gamepad_stick_processor: GamepadStickProcessor = GamepadStickProcessor.new(
	InputActions.LEFT_STICK_UP,
	InputActions.LEFT_STICK_DOWN,
	InputActions.LEFT_STICK_LEFT,
	InputActions.LEFT_STICK_RIGHT,
)
@onready var keyboard_thumbstick_simulator: KeyboardThumbstickSimulator = KeyboardThumbstickSimulator.new(
	InputActions.LEFT_STICK_UP_DIGITAL,
	InputActions.LEFT_STICK_DOWN_DIGITAL,
	InputActions.LEFT_STICK_LEFT_DIGITAL,
	InputActions.LEFT_STICK_RIGHT_DIGITAL,
)


func _enter_tree() -> void:
	assert(thumbstick_resource_left != null, Errors.NULL_RESOURCE)
	thumbstick_resource_left.claim_ownership(self)


func _exit_tree() -> void:
	thumbstick_resource_left.release_ownership(self)


func _process(_delta: float) -> void:
	var stick_input: Vector2 = gamepad_stick_processor.process_input()
	var keyboard_input: Vector2 = keyboard_thumbstick_simulator.process_input()
	thumbstick_resource_left.set_value(
		self,
		stick_input if stick_input.length_squared() > keyboard_input.length_squared() else keyboard_input,
	)
