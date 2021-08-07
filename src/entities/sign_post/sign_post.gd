extends StaticBody3D

@export var lfo_resource: Resource

@onready var area: Area3D = get_node("Area3D")
@onready var highlight: Node3D = get_node("Highlight")


func _ready():
	Signals.area_body_entered.connect(self._on_area_body_entered)
	Signals.area_body_exited.connect(self._on_area_body_exited)
	Signals.interaction_highlight_set.connect(self._on_interaction_highlight_set)
	assert(lfo_resource as LfoResource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	if highlight.visible and Input.is_action_just_pressed(&"interact"):
		pass  # TODO: start interaction


func _on_area_body_entered(sender: Area3D, body: PhysicsBody3D):
	if sender == area:
		assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
		Signals.emit_request_interaction_highlight(self)


func _on_area_body_exited(sender: Area3D, body: PhysicsBody3D):
	if sender == area:
		assert(body.name == &"Player", Errors.CONSISTENCY_ERROR)
		Signals.emit_request_interaction_unhighlight(self)


func _on_interaction_highlight_set(sender: Node, target: Node3D):
	highlight.visible = target == self
