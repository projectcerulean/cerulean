class_name Player
extends CharacterBody3D

# States
const DIVE: StringName = &"Dive"
const FALL: StringName = &"Fall"
const GLIDE: StringName = &"Glide"
const IDLE: StringName = &"Idle"
const JUMP: StringName = &"Jump"
const RUN: StringName = &"Run"
const SWIM: StringName = &"Swim"

@export var camera_path := NodePath()

@export var move_acceleration: float = 150.0
@export var move_friction_coefficient: float = 15.0
@export var turn_weight: float = 0.5
@export var move_snap_distance: float = 0.25
@export var jump_speed: float = 10.0
@export var jump_acceleration: float = 10.0
@export var air_control_modifier: float = 0.08

@export var camera_anchor_y_smooth_grounded: float = 0.1
@export var camera_anchor_y_smooth_air: float = 0.08

@export var glide_gravity_modifier: float = 0.05
@export var glide_smooth_weight: float = 0.01
@export var glide_roll_weight: float = 0.05

@export var water_move_acceleration: float = 15.0
@export var water_turn_weight: float = 0.05
@export var water_buoyancy: float = 12.0
@export var water_resistance: float = 2.0
@export var water_state_enter_offset: float = 0.01

@export var underwater_move_acceleration: float = 12.0
@export var underwater_turn_weight: float = 0.05
@export var underwater_resistance: float = 2.0
@export var underwater_roll_weight: float = 0.02

@export var wall_pushback_distance: float = 0.1
@export var y_min: float = -100.0

@onready var camera: Camera3D = get_node(camera_path)
@onready var camera_anchor: Position3D = get_node("CameraAnchor")
@onready var state_machine: StateMachine = get_node("StateMachine")
@onready var raycast: RayCast3D = get_node("RayCast3D")
@onready var coyote_timer: Timer = get_node("CoyoteTimer")
@onready var jump_buffer_timer: Timer = get_node("JumpBufferTimer")
@onready var mesh_root: Node3D = get_node("MeshRoot")

@onready var mesh_map: Dictionary = {
	DIVE: mesh_root.get_node("MeshGlide"),
	FALL: mesh_root.get_node("MeshDefault"),
	GLIDE: mesh_root.get_node("MeshGlide"),
	IDLE: mesh_root.get_node("MeshDefault"),
	JUMP: mesh_root.get_node("MeshDefault"),
	RUN: mesh_root.get_node("MeshDefault"),
	SWIM: mesh_root.get_node("MeshDefault"),
}

@onready var mesh_joint_map: Dictionary = {  # Auto-generate?
	DIVE: [
		mesh_map[DIVE].get_node("Joint"),
		mesh_map[DIVE].get_node("Joint/Joint"),
		mesh_map[DIVE].get_node("Joint/Joint/Joint"),
	],
	FALL: [
		mesh_map[FALL].get_node("Joint"),
		mesh_map[FALL].get_node("Joint/Joint"),
		mesh_map[FALL].get_node("Joint/Joint/Joint"),
	],
	GLIDE: [
		mesh_map[GLIDE].get_node("Joint"),
		mesh_map[GLIDE].get_node("Joint/Joint"),
		mesh_map[GLIDE].get_node("Joint/Joint/Joint"),
	],
	IDLE: [
		mesh_map[IDLE].get_node("Joint"),
		mesh_map[IDLE].get_node("Joint/Joint"),
		mesh_map[IDLE].get_node("Joint/Joint/Joint"),
	],
	JUMP: [
		mesh_map[JUMP].get_node("Joint"),
		mesh_map[JUMP].get_node("Joint/Joint"),
		mesh_map[JUMP].get_node("Joint/Joint/Joint"),
	],
	RUN: [
		mesh_map[RUN].get_node("Joint"),
		mesh_map[RUN].get_node("Joint/Joint"),
		mesh_map[RUN].get_node("Joint/Joint/Joint"),
	],
	SWIM: [
		mesh_map[SWIM].get_node("Joint"),
		mesh_map[SWIM].get_node("Joint/Joint"),
		mesh_map[SWIM].get_node("Joint/Joint/Joint"),
	],
}

var input_vector: Vector3

var facing_direction: Vector3 = Vector3.FORWARD
var move_acceleration_air: float = move_acceleration * air_control_modifier
var move_friction_coefficient_air: float = move_friction_coefficient * air_control_modifier

var water_collision_shapes: Array


func _ready() -> void:
	Signals.connect(Signals.area_body_entered.get_name(), self._on_area_body_entered)
	Signals.connect(Signals.area_body_exited.get_name(), self._on_area_body_exited)

	assert(camera != null)
	assert(camera_anchor != null)
	assert(raycast != null)
	assert(coyote_timer != null)
	assert(jump_buffer_timer != null)
	for node in mesh_map.values():
		var nodeTyped: Node3D = node as Node3D
		assert(nodeTyped != null)
	for nodes in mesh_joint_map.values():
		for node in nodes:
			var nodeTyped: Node3D = node as Node3D
			assert(nodeTyped != null)


func _process(_delta: float) -> void:
	# Check that the facing direction vector is well-formed
	assert(facing_direction.is_normalized())
	assert(facing_direction.y == 0)

	# Update input vector according to thumbstick and camera position
	var camera_vector: Vector3 = camera.global_transform.origin - global_transform.origin
	camera_vector.y = 0.0
	camera_vector = camera_vector.normalized()
	var forward_vector: Vector3 = camera_vector
	var right_vector: Vector3 = -camera_vector.cross(Vector3.UP)
	input_vector = right_vector * CInput.thumbsticks.left.value.x + forward_vector * CInput.thumbsticks.left.value.y

	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	elif input_vector.is_equal_approx(Vector3.ZERO):
		input_vector = Vector3.ZERO

	# The camera anchor is a Position3D which follows a bit after the player for a smoother feel.
	# It has a top level transform, i.e. its position is not directly inherited from the player.
	camera_anchor.position.x = position.x
	camera_anchor.position.z = position.z
	if state_machine.state.name == RUN or state_machine.state.name == IDLE:
		camera_anchor.position.y = lerp(camera_anchor.position.y, position.y, camera_anchor_y_smooth_grounded)
	else:
		camera_anchor.position.y = lerp(camera_anchor.position.y, position.y, camera_anchor_y_smooth_air)

	# Reload scene when falling off the map
	if get_global_transform().origin.y < y_min:
		get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	# Hack to prevent getting stuck on (CSG) edges
	if is_on_wall() and get_slide_count() > 0:
		var normal: Vector3 = Vector3.ZERO
		for i in range(get_slide_count()):
			normal += get_slide_collision(i).normal
		normal.y = 0.0
		normal = normal.normalized()

		if normal.is_normalized():
			var linear_velocity_tmp: Vector3 = linear_velocity
			linear_velocity = wall_pushback_distance * normal
			move_and_slide()
			linear_velocity = linear_velocity_tmp


func _on_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void:
	if body != self:
		return

	var collision_shape: CollisionShape3D = TreeHelper.get_collision_shape_for_area(sender)
	assert(collision_shape != null)

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
