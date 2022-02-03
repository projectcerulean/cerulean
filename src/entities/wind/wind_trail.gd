extends Node3D

@export var speed: float = 1.0
@export var lifetime: float = 4.0

@export var noise_texture: NoiseTexture
@export var noise_strength: float = 1.0

var time: float = 0

@onready var position_horizontal_a: Node3D = get_node("PositionHorizontalA") as Node3D
@onready var position_horizontal_b: Node3D = get_node("PositionHorizontalB") as Node3D
@onready var position_vertical_a: Node3D = get_node("PositionVerticalA") as Node3D
@onready var position_vertical_b: Node3D = get_node("PositionVerticalB") as Node3D
@onready var trail_horizontal: Trail = get_node("Trails/TrailHorizontal") as Trail
@onready var trail_vertical: Trail = get_node("Trails/TrailVertical") as Trail
@onready var noise_texture_data: PackedByteArray = noise_texture.get_image().get_data()
@onready var i_noise_sample: int = randi() % noise_texture_data.size()


func _ready() -> void:
	assert(position_horizontal_a != null, Errors.NULL_NODE)
	assert(position_horizontal_b != null, Errors.NULL_NODE)
	assert(position_vertical_a != null, Errors.NULL_NODE)
	assert(position_vertical_b != null, Errors.NULL_NODE)
	assert(trail_horizontal != null, Errors.NULL_NODE)
	assert(trail_vertical != null, Errors.NULL_NODE)


func _process(delta: float) -> void:
	time += delta
	if time < lifetime:
		trail_horizontal.add_segment(position_horizontal_a.global_transform.origin, position_horizontal_b.global_transform.origin)
		trail_vertical.add_segment(position_vertical_a.global_transform.origin, position_vertical_b.global_transform.origin)

	translate(speed * Vector3.FORWARD + (float(noise_texture_data[i_noise_sample]) / 255.0 - 0.5) * noise_strength * Vector3.UP)
	i_noise_sample = (i_noise_sample + 1) % noise_texture_data.size()
