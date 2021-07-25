# Rewrite this file if/when it is possible to create nested const dictionaries.
# https://github.com/godotengine/godot/issues/50285
class_name Settings
extends Node

enum CameraInvertedValues {
	NORMAL,
	INVERTED,
}

const OPTION_NAME: StringName = &"OPTION_NAME"
const VALUE_NAMES: StringName = &"VALUE_NAMES"
const DEFAULT_VALUE: StringName = &"DEFAULT_VALUE"

const CAMERA_X_INVERTED: StringName = &"CAMERA_X_INVERTED"
const CAMERA_Y_INVERTED: StringName = &"CAMERA_Y_INVERTED"

const CAMERA_INVERTED_VALUE_NAMES: Array[String] = ["Normal", "Inverted"]

const CAMERA_X_INVERTED_OPTION: Dictionary = {
	OPTION_NAME: "Camera X",
	VALUE_NAMES: CAMERA_INVERTED_VALUE_NAMES,
	DEFAULT_VALUE: CameraInvertedValues.NORMAL,
}

const CAMERA_Y_INVERTED_OPTION: Dictionary = {
	OPTION_NAME: "Camera Y",
	VALUE_NAMES: CAMERA_INVERTED_VALUE_NAMES,
	DEFAULT_VALUE: CameraInvertedValues.NORMAL,
}

const SETTINGS: Dictionary = {
	CAMERA_X_INVERTED: CAMERA_X_INVERTED_OPTION,
	CAMERA_Y_INVERTED: CAMERA_Y_INVERTED_OPTION,
}
