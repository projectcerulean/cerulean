class_name IndicatorState extends State

@onready var indicator: Indicator = owner


func _ready() -> void:
	assert(indicator != null, Errors.NULL_NODE)


func enter(old_state: IndicatorState, data := {}) -> void:
	super.enter(old_state, data)
	indicator.get_node(str(name)).visible = true


func exit(new_state: IndicatorState) -> void:
	super.exit(new_state)
	indicator.get_node(str(name)).visible = false
