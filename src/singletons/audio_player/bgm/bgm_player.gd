# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var n_bgm_resource_players: int = 3

var BgmResourcePlayerPreload: PackedScene = preload("bgm_resource_player.tscn")
var bgm_resource_map: Dictionary  # NodePath -> StringName
var bgm_priority_map: Dictionary  # NodePath -> float
var bgm_current: StringName = StringName()


func _ready() -> void:
	Signals.bgm_area_entered.connect(_on_bgm_area_entered)
	Signals.bgm_area_exited.connect(_on_bgm_area_exited)
	Signals.scene_changed.connect(_on_scene_changed)


func _on_bgm_area_entered(sender: NodePath, bgm: StringName, priority: float) -> void:
	bgm_resource_map[sender] = bgm
	bgm_priority_map[sender] = priority
	update_bgm()


func _on_bgm_area_exited(sender: NodePath) -> void:
	bgm_resource_map.erase(sender)
	bgm_priority_map.erase(sender)
	update_bgm()


func _on_scene_changed(_sender: NodePath) -> void:
	bgm_resource_map.clear()
	bgm_priority_map.clear()
	update_bgm()


func update_bgm() -> void:
	bgm_current = StringName()
	var priority_max: float = -INF

	for sender: NodePath in bgm_resource_map.keys():
		var priority: float = bgm_priority_map[sender]
		if priority > priority_max:
			priority_max = priority
			bgm_current = bgm_resource_map[sender]

	if bgm_current != StringName():
		var bgm_resource_player: BgmResourcePlayer = get_node_or_null(str(bgm_current))
		if bgm_resource_player != null:
			move_child(bgm_resource_player, get_child_count())
		else:
			bgm_resource_player = BgmResourcePlayerPreload.instantiate() as BgmResourcePlayer
			assert(bgm_resource_player != null, Errors.NULL_NODE)
			bgm_resource_player.name = bgm_current
			add_child(bgm_resource_player)
			var bgm_resource_path: String = BgmIndex.BGM_INDEX[bgm_current][BgmIndex.BGM_PATH]
			bgm_resource_player.load_bgm_resource(bgm_resource_path)

			if get_child_count() > n_bgm_resource_players:
				get_child(0).queue_free()

	for _bgm_resource_player: Node in get_children():
		var bgm_resource_player: BgmResourcePlayer = _bgm_resource_player as BgmResourcePlayer
		bgm_resource_player.set_enabled(bgm_resource_player.name == bgm_current)

	Signals.emit_bgm_changed(self, bgm_current)
