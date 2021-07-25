extends Node

@export var settings: Resource
@export var settings_file_path: String = "user://settings.cfg"


func _enter_tree() -> void:
	assert(settings as SettingsResource != null, Errors.NULL_RESOURCE)
	assert(settings.settings.size() == Settings.SETTINGS.size())
	for i in range(settings.settings.size()):
		assert(settings.settings.keys()[i] == Settings.SETTINGS.keys()[i], Errors.CONSISTENCY_ERROR)

	for key in settings.settings:
		settings.settings[key] = Settings.SETTINGS[key][Settings.DEFAULT_VALUE]

	var config_file = ConfigFile.new()
	if config_file.load(settings_file_path) == OK:
		for section in config_file.get_sections():
			for key in config_file.get_section_keys(section):
				if key in settings.settings:
					var value_generic: Variant = config_file.get_value(section, key)
					if typeof(value_generic) == TYPE_INT:
						var value: int = value_generic as int
						var n_options: int = Settings.SETTINGS[key][Settings.VALUE_NAMES].size()
						if value >= 0 and value < n_options:
							settings.settings[key] = value


func _ready() -> void:
	SignalsGetter.get_signals().request_setting_update.connect(self._on_request_setting_update)
	SignalsGetter.get_signals().request_settings_save.connect(self._on_request_settings_save)


func _on_request_setting_update(_sender: Node, key: StringName, value: int) -> void:
	var n_options: int = Settings.SETTINGS[key][Settings.VALUE_NAMES].size()
	assert(value >= 0 and value < n_options, Errors.INVALID_ARGUMENT)
	settings.settings[key] = value
	SignalsGetter.get_signals().emit_setting_updated(self, key, value)


func _on_request_settings_save(_sender: Node) -> void:
	var config_file = ConfigFile.new()
	for key in settings.settings:
		config_file.set_value("Settings", key, settings.settings[key])
	config_file.save(settings_file_path)
