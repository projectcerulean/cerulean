extends HBoxContainer

@export var is_settings_option: bool
@export var is_level_option: bool
@export var settings_resource: Resource
@export var key_string: StringName
@export var text_color_normal: Color
@export var text_color_highlight: Color

@onready var key_node: Label = get_node("Key")
@onready var value_node: Label = get_node("Value")


func _ready() -> void:
	Signals.setting_updated.connect(self._on_setting_updated)
	Signals.scene_changed.connect(self._on_scene_changed)

	assert(str(key_string), Errors.INVALID_ARGUMENT)
	assert(key_node != null, Errors.NULL_NODE)
	assert(value_node != null, Errors.NULL_NODE)

	if is_settings_option:
		assert(settings_resource as SettingsResource != null, Errors.NULL_RESOURCE)
		key_node.text = Settings.SETTINGS[key_string][Settings.OPTION_NAME]
		value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]
	elif is_level_option:
		key_node.text = Levels.LEVELS[key_string][Levels.LEVEL_NAME]
		value_node.text = ""
	else:
		key_node.text = key_string
		value_node.text = ""


func set_highlight(highlight: bool) -> void:
	var text_color: Color = text_color_normal
	if highlight:
		text_color = text_color_highlight
	for label in [key_node, value_node]:
		label.set("custom_colors/font_color", text_color)


func adjust_option(delta: int) -> void:
	if is_settings_option:
		var n_options: int = Settings.SETTINGS[key_string][Settings.VALUE_NAMES].size()
		var value_new: int = posmod(settings_resource.settings[key_string] + delta, n_options)
		Signals.emit_request_setting_update(self, key_string, value_new)


func _on_setting_updated(_sender: Node, _key: StringName, _value: int):
	if is_settings_option:
		value_node.text = Settings.SETTINGS[key_string][Settings.VALUE_NAMES][settings_resource.settings[key_string]]


func _on_scene_changed(_sender: Node):
	if is_level_option:
		if Levels.LEVELS[key_string][Levels.LEVEL_PATH] == get_tree().current_scene.scene_file_path:
			value_node.text = "(Current)"
		else:
			value_node.text = ""
