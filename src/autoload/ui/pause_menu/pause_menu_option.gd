extends HBoxContainer

@export var key_string: StringName
@export var value_string: StringName
@export var text_color_normal: Color
@export var text_color_highlight: Color

@onready var key_node: Label = get_node("Key")
@onready var value_node: Label = get_node("Value")


func _ready() -> void:
	assert(str(key_string), Errors.INVALID_ARGUMENT)
	assert(key_node != null, Errors.NULL_NODE)
	assert(value_node != null, Errors.NULL_NODE)

	key_node.text = key_string
	value_node.text = value_string


func set_highlight(highlight: bool) -> void:
	var text_color: Color = text_color_normal
	if highlight:
		text_color = text_color_highlight
	for label in [key_node, value_node]:
		label.set("custom_colors/font_color", text_color)
