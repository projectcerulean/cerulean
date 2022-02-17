extends Node

var bgm_resource: BgmResource = null

@onready var base_player: AudioStreamPlayer = get_node("BasePlayer") as AudioStreamPlayer
@onready var glide_player: AudioStreamPlayer = get_node("GlidePlayer") as AudioStreamPlayer
@onready var rhythm_player: AudioStreamPlayer = get_node("RhythmPlayer") as AudioStreamPlayer


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)

	assert(base_player != null, Errors.NULL_NODE)
	assert(glide_player != null, Errors.NULL_NODE)
	assert(rhythm_player != null, Errors.NULL_NODE)


func _on_scene_changed(sender: Node) -> void:
	if sender.bgm_resource == bgm_resource:
		return

	base_player.stop()
	glide_player.stop()
	rhythm_player.stop()

	bgm_resource = sender.bgm_resource
	if bgm_resource != null:
		base_player.stream = bgm_resource.stream_sample_base
		glide_player.stream = bgm_resource.stream_sample_glide
		rhythm_player.stream = bgm_resource.stream_sample_rhythm

		assert(base_player.stream != null, Errors.NULL_RESOURCE)

		if glide_player.stream != null:
			assert(glide_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)
		if rhythm_player.stream != null:
			assert(rhythm_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)

		base_player.play()
		glide_player.play()
		rhythm_player.play()

		var start_position: float = randf_range(0.0, base_player.stream.get_length())
		base_player.seek(start_position)
		glide_player.seek(start_position)
		rhythm_player.seek(start_position)

	Signals.emit_bgm_changed(self, bgm_resource)
