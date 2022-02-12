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
	Signals.state_exited.connect(self._on_state_exited)

	assert(menu != null, Errors.NULL_NODE)
	assert(menu_options.size() > 0, Errors.NULL_NODE)

	i_hovered_option = 0
	menu.visible = false


func process(delta: float) -> void:
	super.process(delta)
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"ui_up"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option - 1, menu_options.size())
		elif Input.is_action_just_pressed(&"ui_down"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option + 1, menu_options.size())


func enter(old_state: StringName, data := {}) -> void:
	super.enter(old_state, data)
	menu.visible = true


func exit(new_state: StringName) -> void:
	super.exit(new_state)
	menu.visible = false


func get_transition() -> StringName:
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
	return StringName()


func _on_state_exited(sender: Node, state: StringName) -> void:
	if sender == pause_menu.game_state_resource.state_machine and state == GameStates.PAUSE:
		i_hovered_option = 0
