# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2022 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later
extends Label

@export var indent_width: int = 4

@onready var indent: String = " ".repeat(indent_width)


func _ready() -> void:
	update_text()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(InputActions.STATS):
		update_text()
		visible = !visible


func update_text() -> void:
	text = "\n".join([
		"Time:",
		indent + "FPS: %.1f" % Performance.get_monitor(Performance.Monitor.TIME_FPS),
		indent + "Process: %.1f ms" % (Performance.get_monitor(Performance.Monitor.TIME_PROCESS) * 1000.0),
		indent + "Physics process: %.1f ms" % (Performance.get_monitor(Performance.Monitor.TIME_PHYSICS_PROCESS) * 1000.0),
		"Memory:",
		indent + "Static: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.MEMORY_STATIC) / (1024.0 * 1024.0)),
		indent + "Static Max: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.MEMORY_STATIC_MAX) / (1024.0 * 1024.0)),
		indent + "Msg Buf Max: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.MEMORY_MESSAGE_BUFFER_MAX) / (1024.0 * 1024.0)),
		"Object:",
		indent + "Objects: %d" % round(Performance.get_monitor(Performance.Monitor.OBJECT_COUNT)),
		indent + "Resources: %d" % round(Performance.get_monitor(Performance.Monitor.OBJECT_RESOURCE_COUNT)),
		indent + "Nodes: %d" % round(Performance.get_monitor(Performance.Monitor.OBJECT_NODE_COUNT)),
		indent + "Orphan Nodes: %d" % round(Performance.get_monitor(Performance.Monitor.OBJECT_ORPHAN_NODE_COUNT)),
		"Raster:",
		indent + "Total Objects Drawn: %d" % round(Performance.get_monitor(Performance.Monitor.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		indent + "Total Primitives Drawn: %d" % round(Performance.get_monitor(Performance.Monitor.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		indent + "Total Draw Calls: %d" % round(Performance.get_monitor(Performance.Monitor.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"Video:",
		indent + "Video Mem: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0)),
		indent + "Texture Mem: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.RENDER_TEXTURE_MEM_USED) / (1024.0 * 1024.0)),
		indent + "Buffer Mem: %.1f MiB" % (Performance.get_monitor(Performance.Monitor.RENDER_BUFFER_MEM_USED) / (1024.0 * 1024.0)),
		"Physics:",
		indent + "Active Objects: %d" % round(Performance.get_monitor(Performance.Monitor.PHYSICS_3D_ACTIVE_OBJECTS)),
		indent + "Collision Pairs: %d" % round(Performance.get_monitor(Performance.Monitor.PHYSICS_3D_COLLISION_PAIRS)),
		indent + "Islands: %d" % round(Performance.get_monitor(Performance.Monitor.PHYSICS_3D_ISLAND_COUNT)),
		"Audio:",
		indent + "Output Latency: %.1f ms" % (Performance.get_monitor(Performance.Monitor.AUDIO_OUTPUT_LATENCY) * 1000.0),
	])


func _on_timer_timeout() -> void:
	update_text()
