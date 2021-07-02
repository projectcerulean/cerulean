class_name CColor
extends Node


static func str_to_color(string: String):
	var color_r: float = (str(string).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	var color_g: float = (str(color_r).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	var color_b: float = (str(color_g).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
	return Color(color_r, color_g, color_b).lerp(Color.WHITE, 0.5)
