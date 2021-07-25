extends Node

@export var settings: Resource


func _enter_tree() -> void:
	assert(settings as SettingsResource != null, Errors.NULL_RESOURCE)
	assert(settings.settings.size() == Settings.SETTINGS.size())
	for i in range(settings.settings.size()):
		assert(settings.settings.keys()[i] == Settings.SETTINGS.keys()[i], Errors.CONSISTENCY_ERROR)

	for key in settings.settings:
		settings.settings[key] = Settings.SETTINGS[key][Settings.DEFAULT_VALUE]


func _ready() -> void:
	SignalsGetter.get_signals().request_setting_update.connect(self._on_request_setting_update)


func _on_request_setting_update(_sender: Node, key: StringName, value: int) -> void:
	var n_options: int = Settings.SETTINGS[key][Settings.VALUE_NAMES].size()
	assert(value >= 0 and value < n_options, Errors.INVALID_ARGUMENT)
	settings.settings[key] = value
	SignalsGetter.get_signals().emit_setting_updated(self, key, value)
