extends Node

@onready var bus_index_bgm: int = AudioServer.get_bus_index(AudioBuses.BGM)


func _ready() -> void:
	Signals.setting_updated.connect(_on_setting_updated)
	assert(bus_index_bgm >= 0, Errors.INVALID_AUDIO_BUS)


func _on_setting_updated(_sender: Node, key: StringName, value: int) -> void:
	if key == Settings.BACKGROUND_MUSIC:
		AudioServer.set_bus_mute(bus_index_bgm, value == Settings.Boolean.NO)
