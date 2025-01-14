# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name AudioEffectTransitionListener
extends StateTransitionListener

const wet_level_min: float = 0.0
const wet_level_max: float = 1.0

const TWEEN_TYPE_LINEAR: int = 0
const TWEEN_TYPE_DECIBEL: int = 1
const TWEEN_TYPE_EXPONENTIAL: int = 2

@export var audio_effect_dry: AudioEffect
@export var audio_effect_wet: AudioEffect
@export var audio_bus_name: StringName = AudioBuses.EFFECTS
@export var tween_duration: float = 1.0
@export_enum("Linear", "Decibel", "Exponential") var tween_type: int = TWEEN_TYPE_LINEAR

var audio_effect: AudioEffect
var tween: Tween
var bus_index: int

var wet_level: float:
	get:
		var value: float = clampf(wet_level, 0.0, 1.0)
		if is_nan(value):
			return 0.0
		else:
			return value
	set (value):
		assert(not is_nan(value) and not is_inf(value), Errors.INVALID_ARGUMENT)
		wet_level = value
		for property: Dictionary in audio_effect.get_property_list():
			if property.type == TYPE_FLOAT:
				@warning_ignore("unsafe_cast")
				var dry_value: float = audio_effect_dry.get(property.name as StringName)
				@warning_ignore("unsafe_cast")
				var wet_value: float = audio_effect_wet.get(property.name as StringName)
				var property_value: float
				match tween_type:
					TWEEN_TYPE_LINEAR:
						property_value = lerp(dry_value, wet_value, wet_level)
					TWEEN_TYPE_DECIBEL:
						property_value = linear_to_db(lerpf(db_to_linear(dry_value), db_to_linear(wet_value), wet_level))
					TWEEN_TYPE_EXPONENTIAL:
						assert(dry_value > 0.0 and wet_value > 0.0, Errors.INVALID_ARGUMENT)
						property_value = exp(lerpf(log(dry_value), log(wet_value), wet_level))
				@warning_ignore("unsafe_cast")
				audio_effect.set(property.name as StringName, property_value)


func _enter_tree() -> void:
	assert(audio_effect_dry != null, Errors.NULL_RESOURCE)
	assert(audio_effect_wet != null, Errors.NULL_RESOURCE)
	assert(audio_effect_dry.get_class() == audio_effect_wet.get_class(), Errors.TYPE_ERROR)
	assert(tween_duration >= 0.0, Errors.INVALID_ARGUMENT)

	bus_index = AudioServer.get_bus_index(audio_bus_name)
	assert(bus_index >= 0, Errors.INVALID_AUDIO_BUS)

	audio_effect = audio_effect_dry.duplicate()

	var bus_effect_count: int = AudioServer.get_bus_effect_count(bus_index)
	AudioServer.add_bus_effect(bus_index, audio_effect)
	assert(AudioServer.get_bus_effect_count(bus_index) == bus_effect_count + 1, Errors.CONSISTENCY_ERROR)
	assert(AudioServer.get_bus_effect(bus_index, bus_effect_count) == audio_effect, Errors.CONSISTENCY_ERROR)


func _exit_tree() -> void:
	var bus_effect_count: int = AudioServer.get_bus_effect_count(bus_index)
	for i: int in range(bus_effect_count):
		if AudioServer.get_bus_effect(bus_index, i) == audio_effect:
			AudioServer.remove_bus_effect(bus_index, i)
			break
	assert(AudioServer.get_bus_effect_count(bus_index) == bus_effect_count - 1, Errors.CONSISTENCY_ERROR)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "wet_level", wet_level_max, tween_duration)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "wet_level", wet_level_min, tween_duration)
