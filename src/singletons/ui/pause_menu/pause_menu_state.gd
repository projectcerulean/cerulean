# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
class_name PauseMenuState extends State

@onready var pause_menu: PauseMenu = owner as PauseMenu
@onready var menu: Control = pause_menu.get_node(str(name)) as Control

var i_hovered_option: int:
	set(i_new):
		i_hovered_option = i_new
		for i in menu.get_child_count():
			var menu_option: PauseMenuOption = menu.get_child(i) as PauseMenuOption
			menu_option.set_highlight(i == i_new)


func _ready() -> void:
	Signals.state_exited.connect(_on_state_exited)
	Signals.mouse_entered_control.connect(_on_mouse_entered_control)

	assert(menu != null, Errors.NULL_NODE)
	assert(menu.get_child_count() > 0, Errors.NULL_NODE)

	i_hovered_option = 0
	menu.visible = false


func process(delta: float) -> void:
	super.process(delta)
	if get_game_state() == GameStates.PAUSE:
		if Input.is_action_just_pressed(InputActions.UI_UP):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option - 1, menu.get_child_count())
		elif Input.is_action_just_pressed(InputActions.UI_DOWN):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option + 1, menu.get_child_count())


func enter(data: Dictionary) -> void:
	super.enter(data)
	menu.visible = true


func exit(data: Dictionary) -> void:
	super.exit(data)
	menu.visible = false


func get_transition() -> StringName:
	if get_game_state() == GameStates.PAUSE:
		if Input.is_action_just_pressed(InputActions.PAUSE):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
	return StringName()


func get_game_state() -> StringName:
	var game_state: StringName = (
		pause_menu.game_state_resource.get_current_state() if pause_menu.game_state_resource.is_owned()
		else GameStates.GAMEPLAY
	)
	return game_state


func _on_state_exited(sender: NodePath, state: StringName, _data: Dictionary) -> void:
	if (
		pause_menu.game_state_resource.is_owned()
		and sender == pause_menu.game_state_resource.get_state_machine()
		and state == GameStates.PAUSE
	):
		i_hovered_option = 0


func _on_mouse_entered_control(sender: NodePath) -> void:
	for i in range(menu.get_child_count()):
		var child: Control = menu.get_child(i) as Control
		if child.get_path() == sender:
			if i_hovered_option != i:
				Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
				i_hovered_option = i
			break
