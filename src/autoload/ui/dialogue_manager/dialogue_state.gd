class_name DialogueState
extends State

# Reference to the dialogue manager so that it can be manipulated inside the states
@onready var dialogue_manager: DialogueManager = owner


func _ready() -> void:
	assert(dialogue_manager != null, Errors.NULL_NODE)
