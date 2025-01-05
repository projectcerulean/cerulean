# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Cable
extends MeshInstance3D

@export var flow_speed: float = 50.0
@export var flow_smooth_range: float = 0.5

@onready var box_mesh: BoxMesh = mesh as BoxMesh
@onready var shader_material: ShaderMaterial = get_surface_override_material(0) as ShaderMaterial
@onready var flow_position_start: float = -box_mesh.size.y / 4.0 - flow_smooth_range / 2.0
@onready var flow_position_end: float = -flow_position_start
@onready var flow_duration: float = absf(flow_position_end - flow_position_start) / flow_speed
@onready var state_next: StringName

@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine
@onready var input_node: Node = get_parent().get_child(get_index() - 1)
@onready var tween: Tween


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(box_mesh != null, Errors.NULL_RESOURCE)
	assert(shader_material != null, Errors.NULL_RESOURCE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(input_node != null, Errors.NULL_NODE)

	shader_material.set_shader_parameter("smooth_range", flow_smooth_range)
	shader_material.set_shader_parameter("flip_colors", state_next)
	set_flow_position(flow_position_start)


func set_flow_position(flow_position: float) -> void:
	shader_material.set_shader_parameter("flow_position", flow_position)


func tween_callback() -> void:
	state_machine.transition_to_state(state_next)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	var sender_state_machine: StateMachine = get_node(sender) as StateMachine
	if is_instance_valid(sender_state_machine):
		var sender_state_machine_owner: Node = sender_state_machine.owner
		if is_instance_valid(sender_state_machine_owner) and sender_state_machine_owner == input_node:
			state_next = state
			var flip_colors: bool = state_next == PuzzleElementStates.DISABLED
			shader_material.set_shader_parameter("flip_colors", flip_colors)
			set_flow_position(flow_position_start)

			if tween != null:
				tween.kill()
			tween = create_tween()
			tween.tween_method(set_flow_position, flow_position_start, flow_position_end, flow_duration)
			tween.tween_callback(tween_callback)
