# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Area
extends Area3D


func _on_area_entered(area: Area3D) -> void:
	Signals.emit_area_area_entered(self, area.get_path())


func _on_area_exited(area: Area3D) -> void:
	Signals.emit_area_area_exited(self, area.get_path())


func _on_body_entered(body: PhysicsBody3D) -> void:
	Signals.emit_area_body_entered(self, body.get_path())


func _on_body_exited(body: PhysicsBody3D) -> void:
	Signals.emit_area_body_exited(self, body.get_path())
