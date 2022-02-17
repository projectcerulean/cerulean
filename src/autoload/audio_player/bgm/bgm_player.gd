extends Node

const volume_db_zero: float = -80.0

@export var volume_db_low: float = -30.0
@export var volume_db_high: float = 0.0
@export var tween_duration_glide: float = 3.0
@export var tween_duration_cutoff: float = 0.01
@export var _player_state_resource: Resource

var bgm_resource: BgmResource = null
var base_tween: Tween = null
var glide_tween: Tween = null
var rhythm_tween: Tween = null

@onready var base_player: AudioStreamPlayer = get_node("BasePlayer") as AudioStreamPlayer
@onready var glide_player: AudioStreamPlayer = get_node("GlidePlayer") as AudioStreamPlayer
@onready var rhythm_player: AudioStreamPlayer = get_node("RhythmPlayer") as AudioStreamPlayer
@onready var player_state_resource: StateResource = _player_state_resource as StateResource


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	Signals.state_entered.connect(self._on_state_entered)

	assert(player_state_resource != null, Errors.NULL_RESOURCE)
	assert(base_player != null, Errors.NULL_NODE)
	assert(glide_player != null, Errors.NULL_NODE)
	assert(rhythm_player != null, Errors.NULL_NODE)


func _on_scene_changed(sender: Node) -> void:
	if sender.bgm_resource == bgm_resource:
		return

	base_player.volume_db = volume_db_zero
	glide_player.volume_db = volume_db_zero
	rhythm_player.volume_db = volume_db_zero

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

		if base_tween != null:
			base_tween.kill()
		base_tween = create_tween()
		if base_player.volume_db == volume_db_zero:
			base_tween.tween_property(base_player, "volume_db", volume_db_low, tween_duration_cutoff)
		base_tween.tween_property(base_player, "volume_db", volume_db_high, tween_duration_glide)

	Signals.emit_bgm_changed(self, bgm_resource)


func _on_state_entered(sender: Node, state: StringName) -> void:
	if sender == player_state_resource.state_machine:
		if glide_tween != null:
			glide_tween.kill()
		glide_tween = create_tween()
		if state == PlayerStates.GLIDE:
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
		if state == PlayerStates.GLIDE:
			if rhythm_player.volume_db == volume_db_zero:
				rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_low, tween_duration_cutoff)
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_high, tween_duration_glide)
		else:
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_low, tween_duration_glide)
			rhythm_tween.tween_property(rhythm_player, "volume_db", volume_db_zero, tween_duration_cutoff)
