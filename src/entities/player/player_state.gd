class_name PlayerState extends State

@export var water_state_enter_offset: float = 0.01

# Reference to the player object so that it can be manipulated inside the states
var player: Player = null


func _ready() -> void:
	player = owner as Player
	assert(player != null, Errors.NULL_NODE)
