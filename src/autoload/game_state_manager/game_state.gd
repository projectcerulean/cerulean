class_name GameState extends State

# Reference to the game state manager so that it can be manipulated inside the states
@onready var game_state_manager: GameStateManager = owner as GameStateManager


func _ready() -> void:
	assert(game_state_manager != null, Errors.NULL_NODE)
