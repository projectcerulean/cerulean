extends MeshInstance3D

@export var trail_position_left_path: NodePath
@export var trail_position_right_path: NodePath
@export var max_points: int = 50
@export var target_state_name: StringName

@onready var trail_position_left = get_node(trail_position_left_path)
@onready var trail_position_right = get_node(trail_position_right_path)

var active: bool = false

@onready var pointQueueLeft: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)
@onready var pointQueueRight: DataStructures.RotationQueue = DataStructures.RotationQueue.new(max_points)


func _ready() -> void:
	Signals.connect(Signals.state_entered.get_name(), self._on_state_entered)
	Signals.connect(Signals.state_exited.get_name(), self._on_state_exited)
	assert(trail_position_left != null)
	assert(trail_position_right != null)
	assert(target_state_name != &"")


func _process(_delta: float) -> void:
	if active:
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


func _on_state_entered(sender: Node, state_name: String) -> void:
	if sender.owner == owner and state_name == target_state_name:
		active = true


func _on_state_exited(sender: Node, state_name: String) -> void:
	if sender.owner == owner and state_name == target_state_name:
		active = false
