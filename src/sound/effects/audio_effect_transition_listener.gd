class_name AudioEffectTransitionListener
extends StateTransitionListener

const wet_level_min: float = 0.0
const wet_level_max: float = 1.0

const TWEEN_TYPE_EXPONENTIAL: int = 0
const TWEEN_TYPE_LINEAR: int = 1

@export var audio_effect_dry: AudioEffect
@export var audio_effect_wet: AudioEffect
@export var audio_bus_name: StringName = AudioBuses.EFFECTS
@export var tween_duration: float = 1.0
@export_enum(Exponential, Linear) var tween_type: int = TWEEN_TYPE_EXPONENTIAL

var audio_effect: AudioEffect
var tween: Tween
var wet_level: float

@onready var bus_index: int = AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	super._ready()
	assert(audio_effect_dry != null, Errors.NULL_RESOURCE)
	assert(audio_effect_wet != null, Errors.NULL_RESOURCE)
	assert(audio_effect_dry.get_class() == audio_effect_wet.get_class(), Errors.TYPE_ERROR)
	assert(bus_index >= 0, Errors.INVALID_AUDIO_BUS)
	assert(tween_duration >= 0.0, Errors.INVALID_ARGUMENT)

	audio_effect = audio_effect_dry.duplicate()

	var bus_effect_count: int = AudioServer.get_bus_effect_count(bus_index)
	AudioServer.add_bus_effect(bus_index, audio_effect)
	assert(AudioServer.get_bus_effect_count(bus_index) == bus_effect_count + 1, Errors.CONSISTENCY_ERROR)
	assert(AudioServer.get_bus_effect(bus_index, bus_effect_count) == audio_effect, Errors.CONSISTENCY_ERROR)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var bus_effect_count: int = AudioServer.get_bus_effect_count(bus_index)
		for i in range(bus_effect_count):
			if AudioServer.get_bus_effect(bus_index, i) == audio_effect:
				AudioServer.remove_bus_effect(bus_index, i)
				break
		assert(AudioServer.get_bus_effect_count(bus_index) == bus_effect_count - 1, Errors.CONSISTENCY_ERROR)


func _on_target_state_entered() -> void:
	super._on_target_state_entered()
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_method(set_wet_level, wet_level, wet_level_max, tween_duration)


func _on_target_state_exited() -> void:
	super._on_target_state_exited()
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_method(set_wet_level, wet_level, wet_level_min, tween_duration)


func set_wet_level(wet_level_new: float):
	assert(wet_level_new >= wet_level_min and wet_level_new <= wet_level_max, Errors.INVALID_ARGUMENT)
	wet_level = wet_level_new
	for property in audio_effect.get_property_list():
		if property.type == TYPE_FLOAT:
			var value: float = 0.0
			if tween_type == TWEEN_TYPE_EXPONENTIAL:
				value = exp(lerp(log(audio_effect_dry.get(property.name)), log(audio_effect_wet.get(property.name)), wet_level))
			elif tween_type == TWEEN_TYPE_LINEAR:
				value = lerp(audio_effect_dry.get(property.name), audio_effect_wet.get(property.name), wet_level)
			audio_effect.set(property.name, value)
