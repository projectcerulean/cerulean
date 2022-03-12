class_name PauseMenuOption
extends HBoxContainer

@export var is_settings_option: bool
@export var is_level_option: bool
@export var _settings_resource: Resource
@export var key_string: StringName
@export var text_color_normal: Color
@export var text_color_highlight: Color

@onready var key_node: Label = get_node("Key") as Label
@onready var value_node: Label = get_node("Value") as Label
@onready var settings_resource: SettingsResource = _settings_resource as SettingsResource


func _ready() -> void:
	Signals.setting_updated.connect(self._on_setting_updated)
	Signals.scene_changed.connect(self._on_scene_changed)

	assert(str(key_string), Errors.INVALID_ARGUMENT)
	assert(key_node != null, Errors.NULL_NODE)
	assert(value_node != null, Errors.NULL_NODE)
	assert(settings_resource != null, Errors.NULL_RESOURCE)

	value_node.text = ""

	if is_settings_option:
		key_node.text = Settings.SETTINGS[key_string][Settings.OPTION_NAME]
	elif is_level_option:
		key_node.text = Levels.LEVELS[key_string][Levels.LEVEL_NAME]
	else:
		key_node.text = key_string


func set_highlight(highlight: bool) -> void:
	var text_color: Color = text_color_normal
	if highlight:
		text_color = text_color_highlight
	key_node.set("theme_override_colors/font_color", text_color)
	value_node.set("theme_override_colors/font_color", text_color)


func adjust_option(delta: int) -> void:
	if is_settings_option:
		var n_options: int = len(Settings.SETTINGS[key_string][Settings.VALUE_NAMES])
		var value_new: int = posmod(settings_resource.settings[key_string] + delta, n_options)
		Signals.emit_request_setting_update(self, key_string, value_new)


func _on_setting_updated(_sender: Node, _key: StringName, _value: int) -> void:
	if is_settings_option:
		value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]


func _on_scene_changed(_sender: Node) -> void:
	if is_level_option:
		if Levels.LEVELS[key_string][Levels.LEVEL_PATH] == get_tree().current_scene.scene_file_path:
			value_node.text = "(Current)"
		else:
			value_node.text = ""
