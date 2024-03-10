# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var speed: float = 1.0
@export var lifetime: float = 4.0

@export var noise_texture: NoiseTexture2D
@export var noise_strength: float = 0.5
@export var _environment_resource: Resource

var time: float = 0

@onready var position_horizontal_a: Node3D = get_node("PositionHorizontalA") as Node3D
@onready var position_horizontal_b: Node3D = get_node("PositionHorizontalB") as Node3D
@onready var position_vertical_a: Node3D = get_node("PositionVerticalA") as Node3D
@onready var position_vertical_b: Node3D = get_node("PositionVerticalB") as Node3D
@onready var trail_horizontal: Trail = get_node("Trails/TrailHorizontal") as Trail
@onready var trail_vertical: Trail = get_node("Trails/TrailVertical") as Trail
@onready var water_detector: WaterDetector = get_node("WaterDetector") as WaterDetector
@onready var environment_resource: EnvironmentResource = _environment_resource as EnvironmentResource
@onready var noise_texture_data: PackedByteArray = noise_texture.get_image().get_data()
@onready var i_noise_sample: int = randi() % noise_texture_data.size()


func _ready() -> void:
	assert(position_horizontal_a != null, Errors.NULL_NODE)
	assert(position_horizontal_b != null, Errors.NULL_NODE)
	assert(position_vertical_a != null, Errors.NULL_NODE)
	assert(position_vertical_b != null, Errors.NULL_NODE)
	assert(trail_horizontal != null, Errors.NULL_NODE)
	assert(trail_vertical != null, Errors.NULL_NODE)
	assert(water_detector != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	time += delta

	var color: Color = environment_resource.value.wind_trail_color
	if water_detector.is_in_water():
		color = environment_resource.value.water_trail_color

	if time < lifetime:
		trail_horizontal.add_segment(position_horizontal_a.global_position, position_horizontal_b.global_position, color)
		trail_vertical.add_segment(position_vertical_a.global_position, position_vertical_b.global_position, color)

	translate(speed * Vector3.FORWARD + (float(noise_texture_data[i_noise_sample]) / 255.0 - 0.5) * noise_strength * Vector3.UP)
	i_noise_sample = (i_noise_sample + 1) % noise_texture_data.size()
