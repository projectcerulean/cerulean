class_name PauseMenuState extends State

@onready var pause_menu: Control = owner
@onready var menu: Control = pause_menu.get_node(str(name))
@onready var menu_options: Array = menu.get_children()

var i_hovered_option: int:
	set(i_new):
		i_hovered_option = i_new
		for i in range(menu_options.size()):
			menu_options[i].set_highlight(i == i_new)


func _ready() -> void:
	SignalsGetter.get_signals().state_exited.connect(self._on_state_exited)

	assert(menu != null, Errors.NULL_NODE)
	assert(menu_options.size() > 0, Errors.NULL_NODE)

	i_hovered_option = 0
	menu.visible = false


func process(delta: float) -> void:
	super.process(delta)
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"ui_up"):
			i_hovered_option = posmod(i_hovered_option - 1, menu_options.size())
		elif Input.is_action_just_pressed(&"ui_down"):
			i_hovered_option = posmod(i_hovered_option + 1, menu_options.size())


func enter(old_state: PauseMenuState, data := {}) -> void:
	super.enter(old_state, data)
	menu.visible = true


func exit(new_state: PauseMenuState) -> void:
	super.exit(new_state)
	menu.visible = false


func get_transition() -> PauseMenuState:
	if pause_menu.game_state.state == pause_menu.game_state.states.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			SignalsGetter.get_signals().emit_request_game_unpause(self)
			return state.states.MAIN
	return null


func _on_state_exited(sender: Node, state: Node):
	if sender == pause_menu.game_state.state_machine and state == pause_menu.game_state.states.PAUSE:
		i_hovered_option = 0