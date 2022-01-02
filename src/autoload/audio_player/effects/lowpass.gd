class_name Lowpass
extends Node

@onready var bus_index: int = AudioServer.get_bus_index(self.name)
@onready var audio_effect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter


func _ready() -> void:
	assert(bus_index >= 0, Errors.INVALID_AUDIO_BUS)
	assert(audio_effect != null, Errors.NULL_RESOURCE)
	assert(AudioServer.get_bus_effect_count(bus_index) == 1, Errors.CONSISTENCY_ERROR)
