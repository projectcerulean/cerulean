# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2025 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends RichTextLabel

@export var lines_to_show: int = 25

var buffer: PackedStringArray = []


func _ready() -> void:
	Signals.debug_write.connect(_on_debug_write)


func _on_debug_write(sender: NodePath, variant: Variant) -> void:
	if buffer.size() == lines_to_show:
		buffer.remove_at(0)

	var string: String = str(variant)
	var sender_name: StringName = NodePathUtils.get_node_name(sender)
	var hex_color: String = ColorUtils.variant_to_color(sender_name).to_html(false)
	buffer.append("[color=#%s][code][%s]:[/code][/color] %s" % [hex_color, sender_name, string])
	text = "\n".join(buffer)
	visible = true
