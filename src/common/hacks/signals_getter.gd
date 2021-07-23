# Workaround for https://github.com/godotengine/godot/issues/50471
# When a fix is implemented, remove this file and run:
# cd <repo root>
# find . -name '*.gd' | xargs sed -i 's/SignalsGetter.get_signals()/Signals/g'
class_name SignalsGetter
extends Node


static func get_signals() -> Node:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	return scene_tree.root.get_node("Signals")
