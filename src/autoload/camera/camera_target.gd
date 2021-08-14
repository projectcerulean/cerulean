extends Position3D

@export var transform_resource: Resource
@export var player_transform_resource: Resource
@export var player_state_resource: Resource
@export var game_state_resource: Resource

@export var y_smooth_player_grounded: float = 0.1
@export var y_smooth_player_air: float = 0.08


func _ready() -> void:
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(transform_resource as TransformResource != null, Errors.NULL_RESOURCE)
	assert(player_transform_resource as TransformResource != null, Errors.NULL_RESOURCE)


func _process(delta: float) -> void:
	if game_state_resource.state == game_state_resource.states.DIALOGUE:
		pass
	elif game_state_resource.state == game_state_resource.states.GAMEPLAY:
		global_transform.origin.x = player_transform_resource.global_transform.origin.x
		global_transform.origin.z = player_transform_resource.global_transform.origin.z
		var y_smooth = y_smooth_player_grounded if player_state_resource.state in [player_state_resource.states.RUN, player_state_resource.states.IDLE] else y_smooth_player_air
		global_transform.origin.y = lerp(global_transform.origin.y, player_transform_resource.global_transform.origin.y, y_smooth)
	elif game_state_resource.state == game_state_resource.states.PAUSE:
		pass
	else:
		assert(false, Errors.CONSISTENCY_ERROR)

	# Update tranform resource
	transform_resource.global_transform = global_transform
	transform_resource.transform = transform


func _on_scene_changed(sender: Node):
	global_transform.origin = player_transform_resource.global_transform.origin
