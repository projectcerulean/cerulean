extends Node

@export var _settings_resource: Resource

@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource


func _ready() -> void:
	Signals.setting_updated.connect(_on_setting_updated)
	assert(settings_resource != null, Errors.NULL_RESOURCE)
	DisplayServer.window_set_vsync_mode(Settings.SETTINGS.VSYNC.VALUES[settings_resource.settings[Settings.VSYNC]])


func _on_setting_updated(_sender: Node, key: StringName) -> void:
	if key == Settings.VSYNC:
		DisplayServer.window_set_vsync_mode(Settings.SETTINGS.VSYNC.VALUES[settings_resource.settings[Settings.VSYNC]])
