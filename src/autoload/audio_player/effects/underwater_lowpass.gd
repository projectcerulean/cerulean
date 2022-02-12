extends Lowpass

@export var hz_high: float = 20500
@export var hz_low: float = 1000
@export var lerp_weight: float = 0.5238
@export var _player_state_resource: Resource

@onready var player_state_resource: StateResource = _player_state_resource as StateResource


func _ready() -> void:
	super._ready()
	assert(player_state_resource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	var hz_target: float = hz_high
	if player_state_resource.current_state == PlayerStates.DIVE:
		hz_target = hz_low
	audio_effect.cutoff_hz = Lerp.delta_lerp(audio_effect.cutoff_hz, hz_target, lerp_weight, delta)
