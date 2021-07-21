extends Node

@export var player_path := NodePath()

@export var volume_db_low: float = -30.0
@export var volume_db_high: float = 0.0

@export var tween_duration: float = 3.0

@onready var base_player: AudioStreamPlayer = get_node("BasePlayer")
@onready var glide_player: AudioStreamPlayer = get_node("GlidePlayer")
@onready var rhythm_player: AudioStreamPlayer = get_node("RhythmPlayer")

var base_tween: Tween = null
var glide_tween: Tween = null
var rhythm_tween: Tween = null


func _ready() -> void:
	Signals.connect(Signals.state_entered.get_name(), self._on_state_entered)

	assert(base_player != null)
	assert(glide_player != null)
	assert(rhythm_player != null)

	base_player.volume_db = volume_db_low
	glide_player.volume_db = volume_db_low
	rhythm_player.volume_db = volume_db_low

	base_player.stream = load("res://assets/sound/bgm/seaandsky/seaandsky.wav")
	glide_player.stream = load("res://assets/sound/bgm/seaandsky/seaandsky_glide.wav")
	rhythm_player.stream = load("res://assets/sound/bgm/seaandsky/seaandsky_rhythm.wav")

	assert(base_player.stream != null)

	if glide_player.stream != null:
		assert(glide_player.stream.get_length() == base_player.stream.get_length())
	if rhythm_player.stream != null:
		assert(rhythm_player.stream.get_length() == base_player.stream.get_length())

	base_player.play()
	glide_player.play()
	rhythm_player.play()

	var start_position: float = randf_range(0.0, base_player.stream.get_length())
	base_player.seek(start_position)
	glide_player.seek(start_position)
	rhythm_player.seek(start_position)

	if base_tween != null:
		base_tween.kill()
	base_tween = create_tween()
	base_tween.tween_property(base_player, "volume_db", volume_db_high, tween_duration)


func _on_state_entered(sender: Node, state_name: String) -> void:
	var player: Player = sender.owner as Player
	if player != null:
		if glide_tween != null:
			glide_tween.kill()
		glide_tween = create_tween()
		if state_name == player.GLIDE:
			glide_tween.tween_property(glide_player, "volume_db", volume_db_high, tween_duration)
		else:
			glide_tween.tween_property(glide_player, "volume_db", volume_db_low, tween_duration)

		# TODO: control the rhythm layer player depending on the amount of action on-screen
		if rhythm_tween != null:
			rhythm_tween.kill()
		rhythm_tween = create_tween()
		if state_name == player.GLIDE:
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_high, tween_duration)
		else:
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_low, tween_duration)
