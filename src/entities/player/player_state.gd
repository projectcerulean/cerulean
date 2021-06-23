class_name PlayerState extends State


# Reference to the player object so that it can be manipulated inside the states
var player: Player = null


func _ready():
	player = owner as Player
	assert(player != null)
