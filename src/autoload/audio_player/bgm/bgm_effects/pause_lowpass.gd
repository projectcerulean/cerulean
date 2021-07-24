extends Node

@export var hz_high: float = 20500
@export var hz_low: float = 1000
@export var lerp_weight: float = 0.5
@export var game_state: Resource

@onready var bus_index: int = AudioServer.get_bus_index(self.name)
@onready var audio_effect: AudioEffectLowPassFilter = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter


func _ready():
	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)
	assert(bus_index >= 0, Errors.INVALID_AUDIO_BUS)
	assert(audio_effect != null, Errors.NULL_RESOURCE)
	assert(AudioServer.get_bus_effect_count(bus_index) == 1, Errors.CONSISTENCY_ERROR)


func _process(delta: float):
	var hz_target: float = hz_high
	if game_state.state == game_state.states.PAUSE:
		hz_target = hz_low
	audio_effect.cutoff_hz = lerp(audio_effect.cutoff_hz, hz_target, lerp_weight)
