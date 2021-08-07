extends Node

var interactables: Array = []


func _ready() -> void:
	SignalsGetter.get_signals().request_interaction_highlight.connect(self._on_request_interaction_highlight)
	SignalsGetter.get_signals().request_interaction_unhighlight.connect(self._on_request_interaction_unhighlight)
	SignalsGetter.get_signals().scene_changed.connect(self._on_scene_changed)


func _on_request_interaction_highlight(sender: Node3D):
	if sender not in interactables:
		interactables.append(sender)
		# TODO: sort array depending on the distance between player and interactable
		SignalsGetter.get_signals().emit_interaction_highlight_set(self, interactables[-1])


func _on_request_interaction_unhighlight(sender: Node3D):
	if sender in interactables:
		interactables.erase(sender)
		var target: Node3D = interactables[-1] if interactables.size() > 0 else null
		SignalsGetter.get_signals().emit_interaction_highlight_set(self, target)


func _on_scene_changed(sender: Node):
	interactables.clear()
	SignalsGetter.get_signals().emit_interaction_highlight_set(self, null)
