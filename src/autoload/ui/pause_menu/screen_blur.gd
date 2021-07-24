extends ColorRect

@export var lerp_weight: float = 0.5
@export var game_state: Resource

@onready var blur_strength_max: float = material.get_shader_param("blur_strength")

var blur_strength: float = 0.0


func _ready():
	assert(game_state as StateResource != null)


func _process(delta: float):
	var blur_strength_target: float = 0.0
	if game_state.state == game_state.states.PAUSE:
		blur_strength_target = blur_strength_max
	blur_strength = lerp(blur_strength, blur_strength_target, lerp_weight)
	material.set_shader_param("blur_strength", blur_strength)
