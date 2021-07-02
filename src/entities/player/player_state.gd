class_name PlayerState extends State


# Reference to the player object so that it can be manipulated inside the states
var player: Player = null


func _ready():
	player = owner as Player
	assert(player != null)


func enter(data := {}) -> void:
	super.enter(data)

	# Update player mesh
	assert(player.mesh_map.has(self.name))
	for state_name in player.mesh_map:
		if state_name == self.name:
			player.mesh_map[state_name].show()
		elif player.mesh_map[state_name] != player.mesh_map[self.name]:
			player.mesh_map[state_name].hide()

	# Reset mesh joints
	for joint in player.mesh_joint_map[self.name]:
		var jointTyped: Node3D = joint as Node3D
		jointTyped.rotation = Vector3()
		jointTyped.position = Vector3()
