extends ColorRect

@export var lerp_weight: float = 36.12
@export var game_state: Resource

@onready var blur_strength_max: float = material.get_shader_param("blur_strength")

var blur_strength: float = 0.0


func _ready():
	assert(game_state as StateResource != null, Errors.NULL_RESOURCE)


func _process(delta: float):
	var blur_strength_target: float = 0.0
	if game_state.state == game_state.states.PAUSE:
		blur_strength_target = blur_strength_max
	blur_strength = Lerp.delta_lerp(blur_strength, blur_strength_target, lerp_weight, delta)
	material.set_shader_param("blur_strength", blur_strength)
