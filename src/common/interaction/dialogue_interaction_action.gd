class_name DialogueInteractionAction
extends InteractionAction

@export var dialogue_resource: Resource


func _ready() -> void:
	assert(dialogue_resource as DialogueResource != null, Errors.NULL_RESOURCE)


func interact() -> void:
	super.interact()
	Signals.emit_request_dialogue_start(self, dialogue_resource)
