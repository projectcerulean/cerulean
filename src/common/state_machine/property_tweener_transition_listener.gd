class_name PropertyTweenerTransitionListener
extends StateTransitionListener

@export var _target_node: NodePath
@export var property: String
@export var value_min: float = 0.0
@export var value_max: float = 1.0
@export var tween_duration: float = 1.0

var tween: Tween

@onready var target_node: Node = get_node(_target_node) as Node


func _ready() -> void:
	super._ready()
	assert(target_node != null, Errors.NULL_NODE)
	assert(property != null and not property.is_empty(), Errors.INVALID_ARGUMENT)


func _on_target_state_entered(data: Dictionary) -> void:
	super._on_target_state_entered(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target_node, property, value_max, tween_duration)


func _on_target_state_exited(data: Dictionary) -> void:
	super._on_target_state_exited(data)
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target_node, property, value_min, tween_duration)
