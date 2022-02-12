class_name SwitchState extends State

@onready var switch: Switch = owner


func _ready() -> void:
	assert(switch != null, Errors.NULL_NODE)


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	switch.crystal.get_node(str(name)).visible = true


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	switch.crystal.get_node(str(name)).visible = false


func process(delta: float) -> void:
	super.process(delta)
	switch.crystal.rotate_x(0.500 * delta * (1 + get_index()))
	switch.crystal.rotate_y(0.250 * delta * (1 + get_index()))
	switch.crystal.rotate_z(0.125 * delta * (1 + get_index()))
