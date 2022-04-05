# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
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
	Signals.state_exited.connect(self._on_state_exited)

	assert(menu != null, Errors.NULL_NODE)
	assert(menu.get_child_count() > 0, Errors.NULL_NODE)

	i_hovered_option = 0
	menu.visible = false


func process(delta: float) -> void:
	super.process(delta)
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"ui_up"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option - 1, menu.get_child_count())
		elif Input.is_action_just_pressed(&"ui_down"):
			Signals.emit_request_sfx_play_non_diegetic(self, pause_menu.sfx_resource_select)
			i_hovered_option = posmod(i_hovered_option + 1, menu.get_child_count())


func enter(data: Dictionary) -> void:
	super.enter(data)
	menu.visible = true


func exit(data: Dictionary) -> void:
	super.exit(data)
	menu.visible = false


func get_transition() -> StringName:
	if pause_menu.game_state_resource.current_state == GameStates.PAUSE:
		if Input.is_action_just_pressed(&"pause"):
			Signals.emit_request_game_unpause(self)
			return PauseMenuStates.MAIN
	return StringName()


func _on_state_exited(sender: Node, state: StringName, _data: Dictionary) -> void:
	if sender == pause_menu.game_state_resource.state_machine and state == GameStates.PAUSE:
		i_hovered_option = 0
