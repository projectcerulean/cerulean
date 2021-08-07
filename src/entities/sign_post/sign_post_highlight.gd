extends Node3D

@export var color_min: Color = Color.DIM_GRAY
@export var color_max: Color = Color.DARK_GRAY

@onready var lfo_resource: LfoResource = owner.lfo_resource
@onready var material_post: ShaderMaterial = get_node("PostHighlight").get_surface_override_material(0)
@onready var material_sign: ShaderMaterial = get_node("SignHighlight").get_surface_override_material(0)


func _ready() -> void:
	assert(material_post != null, Errors.NULL_RESOURCE)
	assert(material_sign != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	var lerp_weight: float = abs(lfo_resource.valueFourth)
	material_post.set_shader_param(&"albedo", color_min.lerp(color_max, lerp_weight))
	material_sign.set_shader_param(&"albedo", color_min.lerp(color_max, lerp_weight))
