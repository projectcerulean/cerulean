# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2023 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Node

@export var n_bgm_resource_players: int = 3

var BgmResourcePlayerPreload: PackedScene = preload("res://src/autoload/audio_player/bgm/bgm_resource_player.tscn")
var bgm_area_map: Dictionary  # Area3D -> StringName
var bgm_current: StringName = StringName()


func _ready() -> void:
	Signals.bgm_area_entered.connect(_on_bgm_area_entered)
	Signals.bgm_area_exited.connect(_on_bgm_area_exited)
	Signals.scene_changed.connect(_on_scene_changed)


func _on_bgm_area_entered(sender: Area3D, bgm: StringName) -> void:
	bgm_area_map[sender] = bgm
	update_bgm()


func _on_bgm_area_exited(sender: Area3D) -> void:
	bgm_area_map.erase(sender)
	update_bgm()


func _on_scene_changed(_sender: Node):
	bgm_area_map.clear()
	update_bgm()


func update_bgm() -> void:
	bgm_current = StringName()
	var area_volume_min: float = INF

	for area in bgm_area_map.keys():
		var collision_shape: CollisionShape3D = TreeUtils.get_collision_shape_for_area(area)
		var area_volume: float = ShapeUtils.calculate_shape_volume(collision_shape.shape)
		if area_volume < area_volume_min:
			area_volume_min = area_volume
			bgm_current = bgm_area_map[area]

	if bgm_current != StringName():
		var bgm_resource_player: BgmResourcePlayer = get_node_or_null(str(bgm_current))
		if bgm_resource_player != null:
			move_child(bgm_resource_player, get_child_count())
		else:
			bgm_resource_player = BgmResourcePlayerPreload.instantiate() as BgmResourcePlayer
			assert(bgm_resource_player != null, Errors.NULL_NODE)
			bgm_resource_player.name = bgm_current
			add_child(bgm_resource_player)

			if get_child_count() > n_bgm_resource_players:
				get_child(0).queue_free()

	for _bgm_resource_player in get_children():
		var bgm_resource_player: BgmResourcePlayer = _bgm_resource_player as BgmResourcePlayer
		bgm_resource_player.set_enabled(bgm_resource_player.name == bgm_current)

	Signals.emit_bgm_changed(self, bgm_current)
