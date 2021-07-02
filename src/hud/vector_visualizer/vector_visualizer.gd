extends ColorRect

var vectors: Dictionary
var colors: Dictionary


func _ready() -> void:
	Signals.connect(Signals.visualize_vector.get_name(), self._on_visualize_vector)
	assert(rect_size.x == rect_size.y)
	assert(rect_size.x > 0)


func _draw() -> void:
	var center_point: Vector2 = rect_size / 2.0
	var radius: float = rect_size.x / 2.0
	draw_circle(center_point, 16.0, Color.LIGHT_SLATE_GRAY)
	draw_arc(center_point, radius, 0, 2 * PI, 128, Color.LIGHT_SLATE_GRAY, 2.0, true)
	for sender in vectors:
		var vector: Vector2 = vectors[sender]
		if vector.length_squared() > 1.0:
			vector = vector.normalized()
		draw_line(center_point, center_point + vector * radius, colors[sender], 8.0)


func _on_visualize_vector(sender: Node, vector: Vector2):
	visible = true
	vectors[sender] = vector
	if not colors.has(sender):
		var color_r: float = (str(sender.name).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
		var color_g: float = (str(color_r).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
		var color_b: float = (str(color_g).sha256_text().substr(0, 8).hex_to_int() % 255) / 255.0
		colors[sender] = Color(color_r, color_g, color_b).lerp(Color.WHITE, 0.5)
	update()
