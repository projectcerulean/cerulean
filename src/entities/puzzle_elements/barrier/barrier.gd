# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name Barrier
extends StaticBody3D

@export var _input_nodes: Array[NodePath]
@export var input_targets: Array[bool]
@export var fade_duration: float = 0.25

var input_nodes: Array[Node]
var inputs: Array[bool]

@onready var collision_shape: CollisionShape3D = get_node("CollisionShape3D") as CollisionShape3D
@onready var mesh_instance: MeshInstance3D = get_node("MeshInstance3D") as MeshInstance3D
@onready var state_machine: StateMachine = get_node("StateMachine") as StateMachine
@onready var tween: Tween
@onready var shader_material: ShaderMaterial = mesh_instance.get_surface_override_material(0) as ShaderMaterial


func _ready() -> void:
	Signals.state_entered.connect(self._on_state_entered)
	assert(len(_input_nodes) == len(input_targets), Errors.INVALID_ARGUMENT)
	assert(collision_shape != null, Errors.NULL_NODE)
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(state_machine != null, Errors.NULL_NODE)
	assert(shader_material != null, Errors.NULL_RESOURCE)

	input_nodes.resize(len(input_targets))
	inputs.resize(len(input_targets))

	for i: int in range(len(_input_nodes)):
		input_nodes[i] = get_node(_input_nodes[i])
		assert(input_nodes[i] != null, Errors.NULL_NODE)
		for j: int in range(len(_input_nodes)):
			if i == j:
				continue
			assert(input_nodes[i] != input_nodes[j], Errors.INVALID_ARGUMENT)


func _on_state_entered(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	var inputs_changed: bool = false
	for i: int in range(len(inputs)):
		var sender_state_machine: Node = get_node(sender)
		if is_instance_valid(sender_state_machine):
			var state_machine_owner: Node = sender_state_machine.owner
			if is_instance_valid(state_machine_owner) and state_machine_owner == input_nodes[i]:
				assert(state in [PuzzleElementStates.DISABLED, PuzzleElementStates.ENABLED], Errors.CONSISTENCY_ERROR)
				inputs[i] = state == PuzzleElementStates.ENABLED
				inputs_changed = true

	if inputs_changed:
		var state_name: StringName = PuzzleElementStates.DISABLED if inputs == input_targets else PuzzleElementStates.ENABLED
		state_machine.transition_to_state(state_name)


func set_alpha(alpha: float) -> void:
	shader_material.set_shader_parameter("alpha_factor", alpha)
