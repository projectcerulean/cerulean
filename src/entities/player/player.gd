class_name Player
extends CharacterBody3D

@export var thumbstick_resource_left: Resource
@export var state_resource: Resource
@export var game_state_resource: Resource
@export var transform_resource: Resource
@export var camera_transform_resource: Resource

@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var turn_weight: float = 36.12
@export var move_snap_distance: float = 0.25
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 10.0
@export var air_control_modifier: float = 0.08

@export var glide_gravity_modifier: float = 0.05
@export var glide_smooth_weight: float = 0.5238
@export var glide_roll_weight: float = 2.673

@export var water_move_acceleration: float = 15.0
@export var water_turn_weight: float = 2.673
@export var water_buoyancy: float = 12.0
@export var water_resistance: float = 2.0
@export var water_state_enter_offset: float = 0.01
@export var water_jump_max_surface_distance: float = 0.01

@export var underwater_move_acceleration: float = 12.0
@export var underwater_turn_weight: float = 2.673
@export var underwater_resistance: float = 2.0
@export var underwater_roll_weight: float = 1.053

@onready var raycast: RayCast3D = get_node("RayCast3D")
@onready var coyote_timer: Timer = get_node("CoyoteTimer")
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer")
@onready var mesh_root: Node3D = get_node("MeshRoot")

@onready var mesh_map: Dictionary = {
	state_resource.states.DIVE: mesh_root.get_node("MeshGlide"),
	state_resource.states.FALL: mesh_root.get_node("MeshDefault"),
	state_resource.states.GLIDE: mesh_root.get_node("MeshGlide"),
	state_resource.states.IDLE: mesh_root.get_node("MeshDefault"),
	state_resource.states.JUMP: mesh_root.get_node("MeshDefault"),
	state_resource.states.RUN: mesh_root.get_node("MeshDefault"),
	state_resource.states.SWIM: mesh_root.get_node("MeshDefault"),
}

var mesh_joint_map: Dictionary

var input_vector: Vector3

var facing_direction: Vector3 = Vector3.FORWARD
var move_acceleration_air: float = move_acceleration * air_control_modifier
var move_friction_coefficient_air: float = move_friction_coefficient * air_control_modifier

var water_collision_shapes: Array


func _ready() -> void:
	Signals.area_body_entered.connect(self._on_area_body_entered)
	Signals.area_body_exited.connect(self._on_area_body_exited)

	assert(thumbstick_resource_left as ThumbstickResource != null, Errors.NULL_RESOURCE)
	assert(state_resource as StateResource != null, Errors.NULL_RESOURCE)
	assert(game_state_resource as StateResource != null, Errors.NULL_RESOURCE)
	assert(transform_resource as TransformResource != null, Errors.NULL_RESOURCE)
	assert(camera_transform_resource as TransformResource != null, Errors.NULL_RESOURCE)
	assert(raycast != null, Errors.NULL_NODE)
	assert(coyote_timer != null, Errors.NULL_NODE)
	assert(jump_buffer_timer != null, Errors.NULL_NODE)
	for node in mesh_map.values():
		var nodeTyped: Node3D = node as Node3D
		assert(nodeTyped != null, Errors.NULL_NODE)

	for s in state_resource.states.values():
		mesh_joint_map[s] = [
			mesh_map[s].get_node("Joint"),
			mesh_map[s].get_node("Joint/Joint"),
			mesh_map[s].get_node("Joint/Joint/Joint"),
		]

	for nodes in mesh_joint_map.values():
		for node in nodes:
			var nodeTyped: Node3D = node as Node3D
			assert(nodeTyped != null, Errors.NULL_NODE)

	# Update tranform resource
	transform_resource.global_transform = global_transform
	transform_resource.transform = transform


func _process(_delta: float) -> void:
	# Check that the facing direction vector is well-formed
	assert(facing_direction.is_normalized(), Errors.CONSISTENCY_ERROR)
	assert(facing_direction.y == 0, Errors.CONSISTENCY_ERROR)

	# Update input vector according to thumbstick and camera position
	var camera_vector: Vector3 = camera_transform_resource.global_transform.origin - global_transform.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)
	input_vector = right_vector * thumbstick_resource_left.value.x + forward_vector * thumbstick_resource_left.value.y

	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	elif input_vector.is_equal_approx(Vector3.ZERO):
		input_vector = Vector3.ZERO

	# Update tranform resource
	transform_resource.global_transform = global_transform
	transform_resource.transform = transform

	# Perform interaction
	if Input.is_action_just_pressed(&"interact"):
		if game_state_resource.current_state == game_state_resource.states.GAMEPLAY:
			Signals.emit_request_interaction(self)

	# Pause the game
	if Input.is_action_just_pressed(&"pause"):
		if game_state_resource.current_state == game_state_resource.states.GAMEPLAY:
			Signals.emit_request_game_pause(self)


func _on_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)
	assert(collision_shape != null, Errors.NULL_NODE)

	if str(sender.owner.name).begins_with("Water"):
		water_collision_shapes.append(collision_shape)


func _on_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)

	if collision_shape in water_collision_shapes:
		water_collision_shapes.erase(collision_shape)


func is_in_water():
	return water_collision_shapes.size() > 0


func get_water_surface_height():
	if not is_in_water():
		return NAN

	var height: float = -INF
	for shape in water_collision_shapes:
		height = max(height, shape.global_transform.origin.y + shape.shape.size.y / 2.0)
	return height
