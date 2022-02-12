class_name PlayerState extends State

@export var _mesh_root: NodePath

# Reference to the player object so that it can be manipulated inside the states
var player: Player = null

@onready var mesh_root: Node3D = get_node(_mesh_root) as Node3D


func _ready() -> void:
	player = owner as Player
	assert(player != null, Errors.NULL_NODE)
	assert(mesh_root != null, Errors.NULL_NODE)


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	mesh_root.show()
	mesh_root.transform = Transform3D()


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	mesh_root.hide()
	mesh_root.transform = Transform3D()
