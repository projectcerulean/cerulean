extends Position3D

@export var transform_resource: Resource
@export var player_transform_resource: Resource
@export var player_state_resource: Resource
@export var game_state_resource: Resource

@export var y_lerp_weight_player_grounded: float = 5.491
@export var y_lerp_weight_player_air: float = 4.345

@export var dialogue_lerp_weight: float = 5.491

var dialogue_target: Node3D
var dialogue_target_offset: Vector3
var dialogue_target_position_start: Vector3


func _ready() -> void:
	SignalsGetter.get_signals().scene_changed.connect(self._on_scene_changed)
	SignalsGetter.get_signals().request_dialogue_start.connect(self._on_request_dialogue_start)
	assert(transform_resource as TransformResource != null, Errors.NULL_RESOURCE)
	assert(player_transform_resource as TransformResource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	if game_state_resource.state == game_state_resource.states.DIALOGUE:
		if dialogue_target != null:
			dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, (dialogue_target.global_transform.origin - player_transform_resource.global_transform.origin) / 2.0, dialogue_lerp_weight, delta)
			global_transform.origin = dialogue_target_position_start + dialogue_target_offset
	elif game_state_resource.state == game_state_resource.states.GAMEPLAY:
		dialogue_target_offset = Lerp.delta_lerp3(dialogue_target_offset, Vector3.ZERO, dialogue_lerp_weight, delta)
		global_transform.origin.x = player_transform_resource.global_transform.origin.x + dialogue_target_offset.x
		global_transform.origin.z = player_transform_resource.global_transform.origin.z + dialogue_target_offset.z
		var y_lerp_weight = y_lerp_weight_player_grounded if player_state_resource.state in [player_state_resource.states.RUN, player_state_resource.states.IDLE] else y_lerp_weight_player_air
		global_transform.origin.y = Lerp.delta_lerp(global_transform.origin.y, player_transform_resource.global_transform.origin.y, y_lerp_weight, delta)
	elif game_state_resource.state == game_state_resource.states.PAUSE:
		pass
	else:
		assert(false, Errors.CONSISTENCY_ERROR)

	# Update tranform resource
	transform_resource.global_transform = global_transform
	transform_resource.transform = transform


func _on_scene_changed(sender: Node):
	global_transform.origin = player_transform_resource.global_transform.origin


func _on_request_dialogue_start(sender: Node3D, _dialogue_resource: DialogueResource) -> void:
	dialogue_target = sender
	dialogue_target_offset = Vector3.ZERO
	dialogue_target_position_start = global_transform.origin
