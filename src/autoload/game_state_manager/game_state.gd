class_name GameState extends State

# Reference to the game state manager so that it can be manipulated inside the states
@onready var game_state_manager: Node = owner


func _ready() -> void:
	assert(game_state_manager != null, Errors.NULL_NODE)


func exit(new_state: GameState) -> void:
	super.exit(new_state)
	game_state_manager.transition = null


func get_transition() -> GameState:
	return game_state_manager.transition
