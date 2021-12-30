class_name SwitchInteractionAction
extends InteractionAction

@onready var switch: Switch = owner


func _ready() -> void:
	assert(switch != null, Errors.NULL_NODE)


func interact() -> void:
	super.interact()
	switch.flip()
