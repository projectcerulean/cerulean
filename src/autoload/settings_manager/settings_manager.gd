extends Node

@export var settings_resource: Resource
@export var settings_file_path: String = "user://settings_resource.cfg"


func _enter_tree() -> void:
	assert(settings_resource as SettingsResource != null, Errors.NULL_RESOURCE)
	assert(settings_resource.settings.size() == Settings.SETTINGS.size(), Errors.CONSISTENCY_ERROR)
	for i in range(settings_resource.settings.size()):
		assert(settings_resource.settings.keys()[i] == Settings.SETTINGS.keys()[i], Errors.CONSISTENCY_ERROR)

	for key in settings_resource.settings:
		settings_resource.settings[key] = Settings.SETTINGS[key][Settings.DEFAULT_VALUE]

	var config_file: ConfigFile = ConfigFile.new()
	if config_file.load(settings_file_path) == OK:
		for section in config_file.get_sections():
			for key in config_file.get_section_keys(section):
				if key in settings_resource.settings:
					var value_generic: Variant = config_file.get_value(section, key)
					if typeof(value_generic) == TYPE_INT:
						var value: int = value_generic as int
						var n_options: int = Settings.SETTINGS[key][Settings.VALUE_NAMES].size()
						if value >= 0 and value < n_options:
							settings_resource.settings[key] = value


func _ready() -> void:
	Signals.request_setting_update.connect(self._on_request_setting_update)
	Signals.request_settings_save.connect(self._on_request_settings_save)


func _on_request_setting_update(_sender: Node, key: StringName, value: int) -> void:
	var n_options: int = Settings.SETTINGS[key][Settings.VALUE_NAMES].size()
	assert(value >= 0 and value < n_options, Errors.INVALID_ARGUMENT)
	settings_resource.settings[key] = value
	Signals.emit_setting_updated(self, key, value)


func _on_request_settings_save(_sender: Node) -> void:
	var config_file: ConfigFile = ConfigFile.new()
	for key in settings_resource.settings:
		config_file.set_value("Settings", key, settings_resource.settings[key])
	config_file.save(settings_file_path)
