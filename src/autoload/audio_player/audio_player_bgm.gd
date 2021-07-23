extends Node

const volume_db_zero: float = -80.0

@export var player_path: NodePath

@export var volume_db_low: float = -30.0
@export var volume_db_high: float = 0.0

@export var tween_duration_glide: float = 3.0
@export var tween_duration_cutoff: float = 0.01

@export var player_state: Resource

@onready var base_player: AudioStreamPlayer = get_node("BasePlayer")
@onready var glide_player: AudioStreamPlayer = get_node("GlidePlayer")
@onready var rhythm_player: AudioStreamPlayer = get_node("RhythmPlayer")

var base_tween: Tween = null
var glide_tween: Tween = null
var rhythm_tween: Tween = null


func _ready() -> void:
	Signals.connect(Signals.state_entered.get_name(), self._on_state_entered)

	assert(player_state as StateResource != null)

	assert(base_player != null)
	assert(glide_player != null)
	assert(rhythm_player != null)

	base_player.volume_db = volume_db_zero
	glide_player.volume_db = volume_db_zero
	rhythm_player.volume_db = volume_db_zero

	var bgm_resource: BgmResource = load("res://src/sound/bgm/seaandsky/seaandsky.tres")

	base_player.stream = bgm_resource.stream_base
	glide_player.stream = bgm_resource.stream_glide
	rhythm_player.stream = bgm_resource.stream_rhythm

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
	if base_player.volume_db == volume_db_zero:
		base_tween.tween_property(base_player, "volume_db", volume_db_low, tween_duration_cutoff)
	base_tween.tween_property(base_player, "volume_db", volume_db_high, tween_duration_glide)


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == player_state.state_machine:
		if glide_tween != null:
			glide_tween.kill()
		glide_tween = create_tween()
		if state == player_state.states.GLIDE:
			if glide_player.volume_db == volume_db_zero:
				glide_tween.tween_property(glide_player, "volume_db", volume_db_low, tween_duration_cutoff)
			glide_tween.tween_property(glide_player, "volume_db", volume_db_high, tween_duration_glide)
		else:
			glide_tween.tween_property(glide_player, "volume_db", volume_db_low, tween_duration_glide)
			glide_tween.tween_property(glide_player, "volume_db", volume_db_zero, tween_duration_cutoff)

		# TODO: control the rhythm layer player depending on the amount of action on-screen
		if rhythm_tween != null:
			rhythm_tween.kill()
		rhythm_tween = create_tween()
		if state == player_state.states.GLIDE:
			if rhythm_player.volume_db == volume_db_zero:
				rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_low, tween_duration_cutoff)
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_high, tween_duration_glide)
		else:
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_low, tween_duration_glide)
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_zero, tween_duration_cutoff)
