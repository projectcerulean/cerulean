extends Node

const seconds_per_minute: float = 60.0

@export var bpm_default: float = 90.0
@export var lfo_resource: Resource

@onready var bpm: float = bpm_default


func _ready() -> void:
	Signals.bgm_changed.connect(self._on_bgm_changed)
	assert(lfo_resource as LfoResource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	# TODO: sync with bgm better
	var angle: float = Time.get_unix_time_from_system() * (TAU * bpm / seconds_per_minute)

	lfo_resource.valueDouble = sin(2.0 * angle)
	lfo_resource.valueWhole = sin(angle)
	lfo_resource.valueHalf = sin(0.5 * angle)
	lfo_resource.valueFourth = sin(0.25 * angle)

	lfo_resource.valueDoubleShifted = cos(2.0 * angle)
	lfo_resource.valueWholeShifted = cos(angle)
	lfo_resource.valueHalfShifted = cos(0.5 * angle)
	lfo_resource.valueFourthShifted = cos(0.25 * angle)


func _on_bgm_changed(sender: Node, bgm_resource: BgmResource) -> void:
	bpm = bgm_resource.bpm if bgm_resource != null else bpm_default
