class_name AudioEffectTransitionListener
extends StateTransitionListener

@export var audio_effect_dry: AudioEffect
@export var audio_effect_wet: AudioEffect
@export var audio_bus_name: StringName = AudioBuses.EFFECTS

var audio_effect: AudioEffect

@onready var bus_index: int = AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	super._ready()
	assert(audio_effect_dry != null, Errors.NULL_RESOURCE)
	assert(audio_effect_wet != null, Errors.NULL_RESOURCE)
	assert(audio_effect_dry.get_class() == audio_effect_wet.get_class(), Errors.TYPE_ERROR)
	assert(bus_index >= 0, Errors.INVALID_AUDIO_BUS)

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
	for property in audio_effect.get_property_list():
		if property.type == TYPE_FLOAT:
			audio_effect.set(property.name, audio_effect_wet.get(property.name))


func _on_target_state_exited() -> void:
	super._on_target_state_exited()
	for property in audio_effect.get_property_list():
		if property.type == TYPE_FLOAT:
			audio_effect.set(property.name, audio_effect_dry.get(property.name))
