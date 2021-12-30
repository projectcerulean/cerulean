extends Node

@export var player_transform_resource: Resource

var interactables: Array = []


func _ready() -> void:
	Signals.request_interaction.connect(self._on_request_interaction)
	Signals.request_interaction_highlight.connect(self._on_request_interaction_highlight)
	Signals.request_interaction_unhighlight.connect(self._on_request_interaction_unhighlight)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(player_transform_resource as TransformResource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	if interactables.size() > 1:
		var hash: int = interactables.hash()
		interactables.sort_custom(interactables_sort)
		if not interactables.hash() == hash:
			Signals.emit_interaction_highlight_set(self, interactables.front())


func _on_request_interaction(sender: Node):
	if interactables.size() > 0:
		interactables.front().interact()


func _on_request_interaction_highlight(sender: Node3D):
	# TODO: prevent interactions through walls
	assert(sender as Interaction != null, Errors.TYPE_ERROR)
	if sender not in interactables:
		interactables.append(sender)
		interactables.sort_custom(interactables_sort)
		Signals.emit_interaction_highlight_set(self, interactables.front())


func _on_request_interaction_unhighlight(sender: Node3D):
	if sender in interactables:
		interactables.erase(sender)
		interactables.sort_custom(interactables_sort)
		var target: Node3D = interactables.front()
		Signals.emit_interaction_highlight_set(self, target)


func _on_scene_changed(sender: Node):
	interactables.clear()
	Signals.emit_interaction_highlight_set(self, null)


func interactables_sort(interactable: Node3D, interactable_other: Node3D) -> bool:
	var dist_squared: float = (interactable.global_transform.origin - player_transform_resource.global_transform.origin).length_squared()
	var dist_squared_other: float = (interactable_other.global_transform.origin - player_transform_resource.global_transform.origin).length_squared()
	return dist_squared < dist_squared_other
