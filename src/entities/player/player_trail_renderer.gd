extends MeshInstance3D

@export var trail_position_left_path: NodePath
@export var trail_position_right_path: NodePath
@export var max_points: int = 50
@export var target_state_name: String
@export var player_state: Resource

@onready var trail_position_left = get_node(trail_position_left_path)
@onready var trail_position_right = get_node(trail_position_right_path)

var target_state: Node = null

@onready var pointQueueLeft: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var pointQueueRight: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)


func _ready() -> void:
	assert(trail_position_left != null, Errors.NULL_NODE)
	assert(trail_position_right != null, Errors.NULL_NODE)
	assert(player_state as StateResource != null, Errors.NULL_RESOURCE)
	assert(target_state_name, Errors.INVALID_ARGUMENT)
	target_state = player_state.states[StringName(target_state_name.to_upper())]
	assert(target_state, Errors.INVALID_ARGUMENT)


func _process(_delta: float) -> void:
	if player_state.state == target_state:
		pointQueueLeft.add(trail_position_left.global_transform.origin - global_transform.origin)
		pointQueueRight.add(trail_position_right.global_transform.origin - global_transform.origin)
	else:
		pointQueueLeft.add(Vector3.ZERO)
		pointQueueRight.add(Vector3.ZERO)

	var pointsToDraw: Array[Vector3] = []
	for iPoint in range(0, pointQueueLeft.size() - 1):
		var p1: Vector3 = pointQueueLeft.get_item(iPoint)
		var p2: Vector3 = pointQueueLeft.get_item(iPoint + 1)
		if p1 != Vector3.ZERO and p2 != Vector3.ZERO:
			pointsToDraw.append(p1)
			pointsToDraw.append(p2)
	for iPoint in range(0, pointQueueRight.size() - 1):
		var p1: Vector3 = pointQueueRight.get_item(iPoint)
		var p2: Vector3 = pointQueueRight.get_item(iPoint + 1)
		if p1 != Vector3.ZERO and p2 != Vector3.ZERO:
			pointsToDraw.append(p1)
			pointsToDraw.append(p2)

	mesh.clear_surfaces()
	if pointsToDraw.size() > 0:
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for point in pointsToDraw:
			mesh.surface_add_vertex(point)
		mesh.surface_end()
