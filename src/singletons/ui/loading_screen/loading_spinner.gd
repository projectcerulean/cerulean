extends ColorRect

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	assert(shader_material != null, Errors.NULL_RESOURCE)
	shader_material.set_shader_parameter(&"color", color)
