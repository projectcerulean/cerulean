extends Node

signal area_area_entered
signal area_area_exited
signal area_body_entered
signal area_body_exited
signal bgm_changed
signal camera_water_entered
signal camera_water_exited
signal debug_write
signal interaction_highlight_set
signal request_dialogue_start
signal request_dialogue_finish
signal request_game_pause
signal request_game_quit
signal request_game_unpause
signal request_interaction_highlight
signal request_interaction_unhighlight
signal request_scene_change
signal request_scene_reload
signal request_setting_update
signal request_settings_save
signal scene_changed
signal setting_updated
signal state_entered
signal state_exited
signal visualize_line
signal visualize_vector


# Assert that all the signals above have a corresponding emission function below
func _ready():
	var node: Node = Node.new()
	var default_signals: Array[String] = []
	var default_methods: Array[String] = []
	for s in node.get_signal_list():
		default_signals.append(s["name"])
	for m in node.get_method_list():
		default_methods.append(m["name"])
	node.queue_free()

	var signals: Array[String] = []
	var methods: Array[String] = []
	for s in get_signal_list():
		signals.append(s["name"])
	for m in get_method_list():
		methods.append(m["name"])

	for signal_name in signals:
		if signal_name not in default_signals:
			assert(("emit_" + signal_name) in methods, Errors.CONSISTENCY_ERROR)

	for method_name in methods:
		if method_name not in default_methods and method_name.begins_with("emit_"):
			assert((method_name.trim_prefix("emit_")) in signals, Errors.CONSISTENCY_ERROR)


# Helper function for emitting signals
func emit(sig: Signal, args: Array) -> void:
	var signal_name: String = sig.get_name()
	#debug_write.emit(args[0], str(signal_name, ", ", args.slice(1, args.size())))
	callv(&"call_deferred", [&"emit_signal", signal_name] + args)


# Public signal emission functions
func emit_area_area_entered(sender: Area3D, area: Area3D) -> void: emit(area_area_entered, [sender, area])
func emit_area_area_exited(sender: Area3D, area: Area3D) -> void: emit(area_area_exited, [sender, area])
func emit_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void: emit(area_body_entered, [sender, body])
func emit_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void: emit(area_body_exited, [sender, body])
func emit_bgm_changed(sender: Node, bgm_resource: BgmResource) -> void: emit(bgm_changed, [sender, bgm_resource])
func emit_camera_water_entered(sender: Camera3D) -> void: emit(camera_water_entered, [sender])
func emit_camera_water_exited(sender: Camera3D) -> void: emit(camera_water_exited, [sender])
func emit_debug_write(sender: Node, variant: Variant) -> void: emit(debug_write, [sender, variant])
func emit_interaction_highlight_set(sender: Node, target: Node3D) -> void: emit(interaction_highlight_set, [sender, target])
func emit_request_dialogue_start(sender: Node3D, dialogue_resource: DialogueResource) -> void: emit(request_dialogue_start, [sender, dialogue_resource])
func emit_request_dialogue_finish(sender: Node) -> void: emit(request_dialogue_finish, [sender])
func emit_request_game_pause(sender: Node) -> void: emit(request_game_pause, [sender])
func emit_request_game_quit(sender: Node) -> void: emit(request_game_quit, [sender])
func emit_request_game_unpause(sender: Node) -> void: emit(request_game_unpause, [sender])
func emit_request_interaction_highlight(sender: Node3D) -> void: emit(request_interaction_highlight, [sender])
func emit_request_interaction_unhighlight(sender: Node3D) -> void: emit(request_interaction_unhighlight, [sender])
func emit_request_scene_change(sender: Node, key: String) -> void: emit(request_scene_change, [sender, key])
func emit_request_scene_reload(sender: Node) -> void: emit(request_scene_reload, [sender])
func emit_request_setting_update(sender: Node, key: StringName, value: int) -> void: emit(request_setting_update, [sender, key, value])
func emit_request_settings_save(sender: Node) -> void: emit(request_settings_save, [sender])
func emit_scene_changed(sender: Node) -> void: emit(scene_changed, [sender])
func emit_setting_updated(sender: Node, key: StringName, value: int) -> void: emit(setting_updated, [sender, key, value])
func emit_state_entered(sender: Node, state: Node) -> void: emit(state_entered, [sender, state])
func emit_state_exited(sender: Node, state: Node) -> void: emit(state_exited, [sender, state])
func emit_visualize_line(sender: Node, point: Vector3) -> void: emit(visualize_line, [sender, point])
func emit_visualize_vector(sender: Node, vector: Vector2) -> void: emit(visualize_vector, [sender, vector])
