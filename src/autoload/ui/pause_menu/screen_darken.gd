extends ColorRect

@export var lerp_weight: float = 36.12
@export var game_state: Resource

@onready var alpha_max: float = color.a


func _ready():
	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)
	color.a = 0.0


func _process(delta: float):
	var alpha_target: float = 0.0
	if game_state.state == game_state.states.PAUSE:
		alpha_target = alpha_max
	color.a = Lerp.delta_lerp(color.a, alpha_target, lerp_weight, delta)
