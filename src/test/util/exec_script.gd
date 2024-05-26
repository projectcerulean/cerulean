# This file is part of Project Cerulean <https://projectcerulean.org>
# Copyright (C) 2021-2024 Martin Gulliksson
# SPDX-License-Identifier: GPL-3.0-or-later

# Stand-alone script that can be run using the Godot '--script' command line parameter.
class_name ExecScript
extends SceneTree


func _init() -> void:
	var main_loop: MainLoop = null
	for i in range(100):
		main_loop = Engine.get_main_loop()
		if main_loop != null:
			break
		await create_timer(0.1).timeout
	if main_loop == null:
		push_error("Failed to get main loop")

	main()
	quit()


# Override this
func main() -> void:
	pass
