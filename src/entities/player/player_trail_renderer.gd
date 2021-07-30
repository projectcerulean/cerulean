extends MeshInstance3D

@export var trail_position_left_inner_path: NodePath
@export var trail_position_left_outer_path: NodePath
@export var trail_position_right_inner_path: NodePath
@export var trail_position_right_outer_path: NodePath
@export var max_points: int = 100
@export var lifetime: float = 1.0
@export var target_state_name: String
@export var player_state: Resource

var target_state: Node = null
var time: float = 0.0

@onready var trail_position_left_inner = get_node(trail_position_left_inner_path)
@onready var trail_position_left_outer = get_node(trail_position_left_outer_path)
@onready var trail_position_right_inner = get_node(trail_position_right_inner_path)
@onready var trail_position_right_outer = get_node(trail_position_right_outer_path)

@onready var point_queue_left_inner: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var point_queue_left_outer: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var point_queue_right_inner: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var point_queue_right_outer: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var time_queue: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)


func _ready() -> void:
	assert(trail_position_left_inner != null, Errors.NULL_NODE)
	assert(trail_position_left_outer != null, Errors.NULL_NODE)
	assert(trail_position_right_inner != null, Errors.NULL_NODE)
	assert(trail_position_right_outer != null, Errors.NULL_NODE)
	assert(player_state as StateResource != null, Errors.NULL_RESOURCE)
	assert(target_state_name, Errors.INVALID_ARGUMENT)
	target_state = player_state.states[StringName(target_state_name.to_upper())]
	assert(target_state, Errors.INVALID_ARGUMENT)


func _process(delta: float) -> void:
	mesh.clear_surfaces()
	time += delta

	if player_state.state == target_state:
		point_queue_left_inner.add(trail_position_left_inner.global_transform.origin - global_transform.origin)
		point_queue_left_outer.add(trail_position_left_outer.global_transform.origin - global_transform.origin)
		point_queue_right_inner.add(trail_position_right_inner.global_transform.origin - global_transform.origin)
		point_queue_right_outer.add(trail_position_right_outer.global_transform.origin - global_transform.origin)
		time_queue.add(time)
	else:
		point_queue_left_inner.add(Vector3.ZERO)
		point_queue_left_outer.add(Vector3.ZERO)
		point_queue_right_inner.add(Vector3.ZERO)
		point_queue_right_outer.add(Vector3.ZERO)
		time_queue.add(NAN)

	assert(point_queue_left_inner.size() == point_queue_left_outer.size(), Errors.CONSISTENCY_ERROR)
	assert(point_queue_right_inner.size() == point_queue_right_outer.size(), Errors.CONSISTENCY_ERROR)
	assert(time_queue.size() == point_queue_left_inner.size(), Errors.CONSISTENCY_ERROR)

	var vertices_left: Array[PackedVector3Array] = get_vertices(point_queue_left_inner, point_queue_left_outer, time_queue)
	for chunk in vertices_left:
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for vertex in chunk:
			mesh.surface_add_vertex(vertex)
		mesh.surface_end()

	var vertices_right: Array[PackedVector3Array] = get_vertices(point_queue_right_inner, point_queue_right_outer, time_queue)
	for chunk in vertices_right:
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for vertex in chunk:
			mesh.surface_add_vertex(vertex)
		mesh.surface_end()


func get_vertices(point_queue_inner, point_queue_outer, time_queue) -> Array[PackedVector3Array]:
	var vertices: Array[PackedVector3Array] = []
	var chunk: PackedVector3Array = []
	for i_point in range(point_queue_inner.size()):
		var point_inner: Vector3 = point_queue_inner.get_item(i_point)
		var point_outer: Vector3 = point_queue_outer.get_item(i_point)
		var point_middle: Vector3 = (point_inner + point_outer) / 2.0
		var age: float = time - time_queue.get_item(i_point)
		if point_inner != Vector3.ZERO and point_outer != Vector3.ZERO and age < lifetime:
			chunk.append(point_inner * (1.0 - age / lifetime) + point_middle * (age / lifetime))
			chunk.append(point_outer * (1.0 - age / lifetime) + point_middle * (age / lifetime))
		else:
			if chunk.size() >= 3:
				vertices.append(chunk)
			chunk = []
	if chunk.size() >= 3:
		vertices.append(chunk)
	chunk = []

	return vertices
