extends Label

@export var characters: String = "N  |  |  |  |  |  E  |  |  |  |  |  S  |  |  |  |  |  W  |  |  |  |  |  "
@export var n_characters_visible: int = 16


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return

	var camera_vector: Vector3 = -camera.global_transform.basis.z
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()

	var camera_angle: float = camera_vector.signed_angle_to(Cardinal.north, Vector3.UP)
	if camera_angle < 0.0:
		camera_angle += 2.0 * PI

	var i_char_middle: int = range_lerp(camera_angle, 0.0, 2.0 * PI, 0.0, len(characters))
	text = ""
	for i in range(i_char_middle - n_characters_visible, i_char_middle + n_characters_visible):
		text += characters.substr((i % characters.length() + characters.length()) % characters.length(), 1)