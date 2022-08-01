# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StateTransitionListener

@export var trail_position_a: Node3D
@export var trail_position_b: Node3D
@export var _water_detector: Area3D
@export var _environment_resource: Resource
@export var point_lifetime: float = 0.5

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
		if water_detector.is_in_water():
			color = environment_resource.value.water_trail_color
		trail.add_segment(trail_position_a.global_position, trail_position_b.global_position, color)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	trail = preload("res://src/entities/effects/trail/trail_seethrough.tscn").instantiate()
	add_child(trail)
	trail.set_lifetime(point_lifetime)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	trail.finalize()
	trail = null
