class_name PlayerState extends State

@export var _mesh: NodePath

# Reference to the player object so that it can be manipulated inside the states
var player: Player = null

@onready var mesh: Node3D = get_node(_mesh) as Node3D
@onready var joint1: Node3D = mesh.get_node("Joint") as Node3D
@onready var joint2: Node3D = mesh.get_node("Joint/Joint") as Node3D
@onready var joint3: Node3D = mesh.get_node("Joint/Joint/Joint") as Node3D


func _ready() -> void:
	player = owner as Player
	assert(player != null, Errors.NULL_NODE)
	assert(mesh != null, Errors.NULL_NODE)
	assert(joint1 != null, Errors.NULL_NODE)
	assert(joint2 != null, Errors.NULL_NODE)
	assert(joint3 != null, Errors.NULL_NODE)


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	mesh.show()
	joint1.transform = Transform3D()
	joint2.transform = Transform3D()
	joint3.transform = Transform3D()


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	mesh.hide()
	joint1.transform = Transform3D()
	joint2.transform = Transform3D()
	joint3.transform = Transform3D()
