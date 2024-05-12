# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Character controller which uses a floating collider for its physics. Using a floating collider
# is a simple way to prevent most issues with uneven terrain, slopes, stairs, etc. The collider is
# loosely attached to the ground using a simulated damped spring, where the spring force attempts to
# keep the body to some specified distance above the ground.
class_name CharacterController
extends PhysicsEntity

@export var floor_angle_max: float = PI / 4.0

@export var floor_distance_target: float = 0.5

@export var hover_spring_constant_factor: float = 250
@export var hover_spring_damping_constant_factor: float = 0.5  # 1.0 = critical damping
@export var hover_shape_cast_target_distance: float = 1.0
@export var hover_force_downwards_enabled: bool = true
@export var hover_force_upwards_enabled: bool = true

@export var mesh_anchor: Node3D
@export var mesh_anchor_constant_offset: Vector3
@export var mesh_anchor_active_lerp_weight: float = 10.0
@export var mesh_anchor_resting_lerp_weight: float = 1.0

@export var planar_move_speed_max: float = 5.0
@export var _planar_movement_pid_p_gain_factor: float = 1.0
@export_range(0.0, 1.0, 0.001) var planar_momentum_conservation_factor: float = 0.0

var _collision_shape_height: float = NAN

var _is_near_floor: bool = false
var _is_on_floor: bool = false

var _floor_distance: float = NAN
var _floor_distance_prev: float = NAN
var _floor_collider: Node3D
var _floor_collision_position: Vector3
var _floor_collision_normal: Vector3
var _floor_velocity_prober_position_prev: Vector3

var _planar_movement_pid_controller: PidController2D

var planar_movement_pid_p_gain_factor: float:
	get:
		return _planar_movement_pid_p_gain_factor
	set(value):
		_planar_movement_pid_p_gain_factor = value
		var planar_movement_p_gain: float = _planar_movement_pid_p_gain_factor * mass
		_planar_movement_pid_controller = PidController2D.new(planar_movement_p_gain, 0.0, 0.0, 0.0)

@onready var hover_spring_constant: float = hover_spring_constant_factor * mass
@onready var hover_spring_damping_constant: float = hover_spring_damping_constant_factor * sqrt(4 * mass * hover_spring_constant)

@onready var hover_ray_cast: RayCast3D = RayCast3D.new()
@onready var hover_shape_cast: ShapeCast3D = ShapeCast3D.new()
@onready var hover_shape_cast_auxilary: ShapeCast3D = ShapeCast3D.new()
@onready var push_button_area: Area3D = Area3D.new()
@onready var _floor_velocity_prober: Node3D = Node3D.new()


func _ready() -> void:
	super._ready()

	var collision_shape: CollisionShape3D = TreeUtils.get_collision_shape_for_body(self)
	assert(collision_shape != null, Errors.NULL_NODE)

	var shape: Shape3D = collision_shape.shape
	assert(shape != null, Errors.NULL_RESOURCE)

	_collision_shape_height = ShapeUtils.get_shape_height(shape)

	hover_ray_cast.target_position = Vector3.DOWN * (_collision_shape_height / 2.0 + hover_shape_cast_target_distance)
	hover_ray_cast.collision_mask = collision_mask
	hover_ray_cast.enabled = false
	add_child(hover_ray_cast)

	hover_shape_cast.shape = shape
	hover_shape_cast.target_position = hover_shape_cast_target_distance * Vector3.DOWN
	hover_shape_cast.collision_mask = collision_mask
	hover_shape_cast.enabled = false
	add_child(hover_shape_cast)

	# Used to call get_closest_collision_safe_fraction() for each individual collider detected by hover_shape_cast
	hover_shape_cast_auxilary.shape = hover_shape_cast.shape
	hover_shape_cast_auxilary.target_position = hover_shape_cast.target_position
	hover_shape_cast_auxilary.collision_mask = hover_shape_cast.collision_mask
	hover_shape_cast_auxilary.enabled = hover_shape_cast.enabled
	add_child(hover_shape_cast_auxilary)

	# Additional collision area that can be monitored by e.g. push buttons on the floor
	push_button_area.monitoring = false
	push_button_area.monitorable = true
	push_button_area.collision_layer = collision_layer
	push_button_area.collision_mask = 0
	add_child(push_button_area)
	var push_button_shape: CollisionShape3D = CollisionShape3D.new()
	push_button_shape.shape = collision_shape.shape
	push_button_area.add_child(push_button_shape)

	_planar_movement_pid_controller = PidController2D.new(_planar_movement_pid_p_gain_factor * mass, 0.0, 0.0, 0.0)

	lock_rotation = true


func _physics_process(delta: float) -> void:
	_is_near_floor = false
	_floor_collider = null
	_floor_distance = NAN
	_floor_collision_position = Vector3.ZERO
	_floor_collision_normal = Vector3.ZERO
	_floor_distance = NAN

	hover_ray_cast.force_raycast_update()
	if hover_ray_cast.is_colliding():
		var floor_angle: float = hover_ray_cast.get_collision_normal().angle_to(Vector3.UP)
		var collision_point: Vector3 = hover_ray_cast.get_collision_point()
		if collision_point.y < hover_ray_cast.global_position.y and floor_angle <= floor_angle_max:
			_is_near_floor = true
			_floor_collider = hover_ray_cast.get_collider() as Node3D
			_floor_collision_position = hover_ray_cast.get_collision_point()
			_floor_collision_normal = hover_ray_cast.get_collision_normal()
			_floor_distance = (hover_ray_cast.get_collision_point() - hover_ray_cast.global_position).length() - _collision_shape_height / 2.0

	hover_shape_cast.force_shapecast_update()
	for i_collision: int in range(hover_shape_cast.get_collision_count()):
		var floor_angle: float = hover_shape_cast.get_collision_normal(i_collision).angle_to(Vector3.UP)
		var collision_point: Vector3 = hover_shape_cast.get_collision_point(i_collision)
		if collision_point.y < hover_shape_cast.global_position.y and floor_angle <= floor_angle_max:
			if hover_shape_cast.get_collision_point(i_collision).y > _floor_collision_position.y or _floor_collider == null:
				_floor_collider = hover_shape_cast.get_collider(i_collision)
				_floor_collision_position = hover_shape_cast.get_collision_point(i_collision)
				_floor_collision_normal = hover_shape_cast.get_collision_normal(i_collision)

				var closest_collision_safe_fraction: float = 0.0
				if hover_shape_cast.get_collision_count() == 1:
					closest_collision_safe_fraction = hover_shape_cast.get_closest_collision_safe_fraction()
				else:
					# Call get_closest_collision_safe_fraction() for only this specific collider
					hover_shape_cast_auxilary.force_shapecast_update()
					for i_collision_auxilary: int in range(hover_shape_cast_auxilary.get_collision_count()):
						if not is_same(hover_shape_cast_auxilary.get_collider(i_collision_auxilary), hover_shape_cast.get_collider(i_collision)):
							hover_shape_cast_auxilary.add_exception_rid(hover_shape_cast_auxilary.get_collider_rid(i_collision_auxilary))
					hover_shape_cast_auxilary.force_shapecast_update()
					assert(hover_shape_cast_auxilary.get_collision_count() == 1, Errors.CONSISTENCY_ERROR)
					assert(is_same(hover_shape_cast_auxilary.get_collider(0), hover_shape_cast.get_collider(i_collision)), Errors.CONSISTENCY_ERROR)
					closest_collision_safe_fraction = hover_shape_cast_auxilary.get_closest_collision_safe_fraction()
					hover_shape_cast_auxilary.clear_exceptions()

				_floor_distance = closest_collision_safe_fraction * hover_shape_cast_target_distance
				if (
					not closest_collision_safe_fraction < 1.0
					or not closest_collision_safe_fraction > 0.0
				):
					# The collision shape is currently intersecting something
					if hover_shape_cast.get_collision_point(i_collision).y > global_position.y:
						_floor_distance = hover_shape_cast_target_distance
					elif hover_shape_cast.get_collision_point(i_collision).y < global_position.y:
						_floor_distance = 0.0
					else:
						_floor_distance = floor_distance_target

	var floor_distance_equilibrium: float = floor_distance_target + mass * total_gravity.y / hover_spring_constant

	if _floor_collider != null:
		_is_near_floor = true

		var hover_force: Vector3 = Vector3.UP * (
			- hover_spring_constant * (_floor_distance - floor_distance_target)
			- linear_velocity.y * hover_spring_damping_constant
		)

		if (
			(hover_force.y > 0.0 and hover_force_upwards_enabled)
			or (hover_force.y < 0.0 and hover_force_downwards_enabled)
		):
			apply_central_force(hover_force)

			# Newton's third
			var colliderBody: RigidBody3D = _floor_collider as RigidBody3D
			if colliderBody != null:
				var force_position_global: Vector3 = _floor_collision_position
				var force_position_local: Vector3 = force_position_global - colliderBody.global_position
				colliderBody.apply_force(-hover_force, force_position_local)

			if not is_nan(_floor_distance_prev):
				if (
					signf(_floor_distance - floor_distance_equilibrium)
					!= signf(_floor_distance_prev - floor_distance_equilibrium)
					or (
						_floor_distance <= floor_distance_equilibrium
						and _floor_distance < _floor_distance_prev
					)
				):
					_is_on_floor = true
		elif hover_force.y < 0.0 and not hover_force_downwards_enabled:
			_is_on_floor = false

		# Update mesh anchor position to line up with the ground
		if _is_on_floor:
			push_button_area.position = Vector3.DOWN * _floor_distance
			if mesh_anchor != null:
				mesh_anchor.position = Lerp.delta_lerp3(
					mesh_anchor.position,
					Vector3.DOWN * _floor_distance + Vector3.UP * mesh_anchor_constant_offset,
					mesh_anchor_active_lerp_weight,
					delta,
				)

		_floor_distance_prev = _floor_distance
	else:
		_is_on_floor = false
		_floor_distance_prev = NAN
		push_button_area.position = Vector3.DOWN * floor_distance_equilibrium
		if mesh_anchor != null:
			mesh_anchor.position = Lerp.delta_lerp3(
				mesh_anchor.position,
				Vector3.UP * floor_distance_equilibrium - mesh_anchor_constant_offset,
				mesh_anchor_resting_lerp_weight,
				delta,
			)

	# Apply floor transform
	var node_reparented: bool = TreeUtils.reparent_node(
		_floor_velocity_prober,
		_floor_collider if _floor_collider != null else self
	)
	var prober_parent: Node3D = _floor_velocity_prober.get_parent() as Node3D
	if prober_parent != null and prober_parent != self and not node_reparented:
		var transform_offset: Vector3 = _floor_velocity_prober.global_position - _floor_velocity_prober_position_prev
		enqueue_transform_offset(transform_offset)
		_floor_velocity_prober.global_position = _floor_collision_position
	_floor_velocity_prober_position_prev = _floor_velocity_prober.global_position

	# Additional bounce area check
	perform_bounce_area_check(-Vector3.UP * floor_distance_target, linear_velocity * delta)


func perform_planar_movement(input_vector: Vector2, process_delta: float) -> void:
	input_vector = input_vector.limit_length()
	var current_planar_velocity: Vector2 = VectorUtils.vec3_xz_to_vec2(linear_velocity)

	var target_planar_velocity: Vector2 = input_vector * planar_move_speed_max
	if current_planar_velocity.length() > planar_move_speed_max and not input_vector.is_zero_approx():
		var delta_angle: float = absf(current_planar_velocity.angle_to(input_vector))
		if delta_angle < PI / 2.0:
			var planar_move_speed_max_extended: float = Math.ellipse(
				Vector2(
					lerpf(planar_move_speed_max, current_planar_velocity.length(), planar_momentum_conservation_factor),
					planar_move_speed_max,
				),
			delta_angle,
			)
			target_planar_velocity = input_vector * planar_move_speed_max_extended

	var planar_movement_force: Vector2 = _planar_movement_pid_controller.update(
		current_planar_velocity,
		target_planar_velocity,
		process_delta,
	)

	enqueue_planar_force(planar_movement_force)


func is_on_floor() -> bool:
	return _is_on_floor


func is_near_floor() -> bool:
	return _is_near_floor


func get_floor_collider() -> Node3D:
	return _floor_collider


func get_floor_collision_position() -> Vector3:
	return _floor_collision_position
