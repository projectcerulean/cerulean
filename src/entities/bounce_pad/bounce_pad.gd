# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends StaticBody3D

@export var bounce_height: float = 2.5
@export var bounce_elasticy: float = sqrt(0.6)  # sqrt(Player.GRAVITY_BOUNCE / Player.GRAVITY_FALL)
@export var color_bounce: Color = Color(1.0, 1.0, 1.0)
@export var color_tween_duration: float = 0.5
@export var _sfx_resource: Resource

var tween: Tween

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var bounce_min_speed: float = 2.0 * sqrt(gravity * bounce_height)
@onready var bounce_area: BounceArea = get_node("BounceArea") as BounceArea
@onready var mesh_instance: MeshInstance3D = get_node("PhysicsStepInterpolator/BounceMesh") as MeshInstance3D
@onready var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
@onready var color_default: Color = material.albedo_color
@onready var sfx_resource: SfxResource = _sfx_resource as SfxResource


func _ready() -> void:
	assert(bounce_area != null, Errors.NULL_NODE)
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(material != null, Errors.NULL_RESOURCE)
	assert(sfx_resource != null, Errors.NULL_RESOURCE)

	bounce_area.bounce_elasticity = bounce_elasticy
	bounce_area.bounce_min_speed = bounce_min_speed
	bounce_area.body_bounced.connect(on_body_bounced)


func on_body_bounced() -> void:
	material.albedo_color = color_bounce
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color", color_default, color_tween_duration)

	Signals.emit_request_sfx_play(self, sfx_resource, global_position)
