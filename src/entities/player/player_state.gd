class_name PlayerState extends State


# Reference to the player object so that it can be manipulated inside the states
var player: Player = null


func _ready() -> void:
	player = owner as Player
	assert(player != null, Errors.NULL_NODE)


func enter(old_state: State, data := {}) -> void:
	super.enter(old_state, data)

	# Update player mesh
	assert(player.mesh_map.has(self), Errors.CONSISTENCY_ERROR)
	for state in player.mesh_map:
		if state == self:
			player.mesh_map[state].show()
		elif player.mesh_map[state] != player.mesh_map[self]:
			player.mesh_map[state].hide()

	# Reset mesh joints
	for joint in player.mesh_joint_map[self]:
		var jointTyped: Node3D = joint as Node3D
		jointTyped.rotation = Vector3()
		jointTyped.position = Vector3()
