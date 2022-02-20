class_name BgmResourcePlayer
extends Node

const volume_db_min: float = -80.0
const volume_db_max: float = 0.0

@export var tween_duration: float = 5.0

var tween: Tween

var volume: float:
	get:
		var value: float = clampf(volume, 0.0, 1.0)
		if is_nan(value):
			return 0.0
		else:
			return value
	set (value):
		assert(not is_nan(value) and not is_inf(value), Errors.INVALID_ARGUMENT)
		volume = clampf(value, 0.0, 1.0)
		for _audio_stream_player in get_children():
			var audio_stream_player: AudioStreamPlayer = _audio_stream_player as AudioStreamPlayer
			audio_stream_player.volume_db = linear2db(lerp(db2linear(volume_db_min), db2linear(volume_db_max), volume))

@onready var base_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var glide_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var rhythm_player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	assert(base_player != null, Errors.NULL_NODE)
	assert(glide_player != null, Errors.NULL_NODE)
	assert(rhythm_player != null, Errors.NULL_NODE)

	add_child(base_player)
	add_child(glide_player)
	add_child(rhythm_player)

	base_player.bus = AudioBuses.BGM_BASE
	glide_player.bus = AudioBuses.BGM_GLIDE
	rhythm_player.bus = AudioBuses.BGM_RHYTHM

	volume = 0.0

	var bgm_resource: BgmResource = load(BgmIndex.BGM_INDEX[name][BgmIndex.BGM_PATH]) as BgmResource
	assert(bgm_resource != null, Errors.NULL_RESOURCE)

	base_player.stream = bgm_resource.stream_sample_base
	glide_player.stream = bgm_resource.stream_sample_glide
	rhythm_player.stream = bgm_resource.stream_sample_rhythm

	assert(base_player.stream != null, Errors.NULL_RESOURCE)
	var start_position: float = randf_range(0.0, base_player.stream.get_length())
	base_player.play()
	base_player.seek(start_position)

	if glide_player.stream != null:
		assert(glide_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)
		glide_player.play()
		glide_player.seek(start_position)
	if rhythm_player.stream != null:
		assert(rhythm_player.stream.get_length() == base_player.stream.get_length(), Errors.INVALID_ARGUMENT)
		rhythm_player.play()
		rhythm_player.seek(start_position)


func set_enabled(enabled: bool):
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "volume", float(enabled), tween_duration)
