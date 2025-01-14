# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var trail_position_a: Node3D
@export var trail_position_b: Node3D
@export var _water_detector: Area3D
@export var _environment_resource: Resource
@export var point_lifetime: float = 0.5
@export var n_subdivisions: int = 2
@export var air_brake_color: Color = Color.ORANGE_RED
@export var air_brake_color_strength: float = 0.4

var trail: Trail = null

@onready var water_detector: WaterDetector = _water_detector as WaterDetector
@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource


func _ready() -> void:
	super._ready()
	assert(trail_position_a != null, Errors.NULL_NODE)
	assert(trail_position_b != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)


func _process(_delta: float) -> void:
	if is_in_target_state and trail != null:
		var color: Color = environment_resource.value.wind_trail_color
		if Input.is_action_pressed(InputActions.AIR_BRAKE):
			color = color.lerp(air_brake_color, air_brake_color_strength)
		if water_detector.is_in_water():
			color = environment_resource.value.water_trail_color
		trail.add_segment(trail_position_a.global_position, trail_position_b.global_position, color)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	trail = preload("../../effects/trail/trail_seethrough.tscn").instantiate()
	add_child(trail)
	trail.set_lifetime(point_lifetime)
	trail.set_n_subdivisions(n_subdivisions)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	trail.finalize()
	trail = null
