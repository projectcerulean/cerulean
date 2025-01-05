# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node3D

@export var settings_resource: SettingsResource
@export var time_resource_gameplay: FloatResource

@export var shake_angular_velocity: Vector3 = Vector3(
	63.0,
	70.0,
	77.0
)

@export var trauma_decay_rate: float = 0.2
@export var trauma_exponent: float = 2.0
@export var max_shake: Vector3 = Vector3(0.25, 0.25, 0.15)

var _trauma: float = 0.0
var _time_prev: float = 0.0
var _sustained_shakes: Array[SustainedShake] = []


func _ready() -> void:
	Signals.request_camera_shake_impulse.connect(_on_request_camera_shake_impulse)
	Signals.request_camera_shake_sustained.connect(_on_request_camera_shake_sustained)
	Signals.request_camera_shake_sustained_stop.connect(_on_request_camera_shake_sustained_stop)
	Signals.scene_changed.connect(_on_scene_changed)
	get_tree().node_removed.connect(_on_node_removed)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	assert(time_resource_gameplay != null, Errors.NULL_RESOURCE)


func _process(_delta: float) -> void:
	rotation = Vector3.ZERO

	@warning_ignore("unsafe_cast")
	var shake_setting_factor: float = Settings.SETTINGS.SCREEN_SHAKE.VALUES[settings_resource.settings[Settings.SCREEN_SHAKE]] as float

	if time_resource_gameplay.is_owned():
		var time: float = time_resource_gameplay.get_value()

		var shake: Vector3 = max_shake * pow(_trauma, trauma_exponent) * Vector3(
			cos(shake_angular_velocity.x * time),
			cos(shake_angular_velocity.y * time),
			cos(shake_angular_velocity.z * time),
		)
		rotation = shake_setting_factor * shake

		var sustained_shake_trauma: float = _get_sustained_shake_trauma(time)
		_prune_sustained_shakes()

		_trauma = maxf(sustained_shake_trauma, _trauma -trauma_decay_rate * (time - _time_prev))
		_time_prev = time
	else:
		_trauma = 0.0


func _on_node_removed(node: Node) -> void:
	_on_request_camera_shake_sustained_stop(node.get_path())


func _on_request_camera_shake_impulse(_sender: NodePath, trauma: float) -> void:
	_trauma = minf(1.0, _trauma + trauma)


func _on_request_camera_shake_sustained(sender: NodePath, camera_shake_resource: CameraShakeSustainedResource) -> void:
	_on_request_camera_shake_sustained_stop(sender)

	if time_resource_gameplay.is_owned():
		var time_start: float = time_resource_gameplay.get_value()
		var shake: SustainedShake = SustainedShake.new(sender, camera_shake_resource, time_start)
		_sustained_shakes.append(shake)


func _on_request_camera_shake_sustained_stop(sender: NodePath) -> void:
	for sustained_shake: SustainedShake in _sustained_shakes:
		if sustained_shake.get_sender() == sender:
			sustained_shake.kill()
	_prune_sustained_shakes()


func _on_scene_changed(_sender: NodePath) -> void:
	if time_resource_gameplay.is_owned():
		var time: float = time_resource_gameplay.get_value()
		_trauma = _get_sustained_shake_trauma(time)
		_prune_sustained_shakes()
	else:
		_trauma = 0.0


func _get_sustained_shake_trauma(time: float) -> float:
	var trauma: float = 0.0
	for sustained_shake: SustainedShake in _sustained_shakes:
		trauma += sustained_shake.update(time)
	return trauma


func _prune_sustained_shakes() -> void:
	var should_prune: bool = false
	for sustained_shake: SustainedShake in _sustained_shakes:
		if not sustained_shake.is_alive():
			should_prune = true
			break
	if should_prune:
		_sustained_shakes = _sustained_shakes.filter(func(shake: SustainedShake) -> bool: return shake.is_alive())


class SustainedShake extends RefCounted:
	var _sender: NodePath
	var _camera_shake_resource: CameraShakeSustainedResource
	var _time_start: float
	var _is_alive: bool

	func _init(sender: NodePath, camera_shake_resource: CameraShakeSustainedResource, time_start: float) -> void:
		_sender = sender
		_camera_shake_resource = camera_shake_resource
		_time_start = time_start
		_is_alive = true

	func update(time: float) -> float:
		var progress: float = (time - _time_start) / _camera_shake_resource.total_duration
		assert(progress >= 0.0, Errors.INVALID_CONTEXT)
		if progress > 1.0:
			_is_alive = false

		if _is_alive:
			var trauma_envelope_value: float = (
				_camera_shake_resource.trauma_envelope.sample(progress) if is_instance_valid(_camera_shake_resource.trauma_envelope)
				else 1.0
			)
			var trauma: float = trauma_envelope_value * _camera_shake_resource.trauma_factor
			return trauma
		else:
			return 0.0

	func kill() -> void:
		_is_alive = false

	func is_alive() -> bool:
		return _is_alive

	func get_sender() -> NodePath:
		return _sender
