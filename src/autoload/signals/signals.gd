extends Node

signal area_area_entered
signal area_area_exited
signal area_body_entered
signal area_body_exited
signal camera_water_entered
signal camera_water_exited
signal debug_write
signal request_game_pause
signal request_game_unpause
signal state_entered
signal state_exited
signal visualize_line
signal visualize_vector


# Assert that all the signals above have a corresponding emission function below
func _ready():
	var node: Node = Node.new()
	var default_signals: Array[String]
	var default_methods: Array[String]
	for s in node.get_signal_list():
		default_signals.append(s["name"])
	for m in node.get_method_list():
		default_methods.append(m["name"])
	node.queue_free()

	var signals: Array[String]
	var methods: Array[String]
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
func emit(args: Array) -> void:
	assert(args[0] as Node != null, Errors.INVALID_ARGUMENT)
	var calling_function_name: String = get_stack()[1][&"function"]
	assert(calling_function_name.begins_with("emit_"), Errors.INVALID_CONTEXT)
	var signal_name: StringName = calling_function_name.trim_prefix("emit_")
	callv(&"call_deferred", [&"emit_signal", signal_name] + args)


# Public signal emission functions
func emit_area_area_entered(sender: Area3D, area: Area3D) -> void: emit([sender, area])
func emit_area_area_exited(sender: Area3D, area: Area3D) -> void: emit([sender, area])
func emit_area_body_entered(sender: Area3D, body: PhysicsBody3D) -> void: emit([sender, body])
func emit_area_body_exited(sender: Area3D, body: PhysicsBody3D) -> void: emit([sender, body])
func emit_camera_water_entered(sender: Camera3D) -> void: emit([sender])
func emit_camera_water_exited(sender: Camera3D) -> void: emit([sender])
func emit_debug_write(sender: Node, variant: Variant) -> void: emit([sender, variant])
func emit_request_game_pause(sender: Node) -> void: emit([sender])
func emit_request_game_unpause(sender: Node) -> void: emit([sender])
func emit_state_entered(sender: Node, state: Node) -> void: emit([sender, state])
func emit_state_exited(sender: Node, state: Node) -> void: emit([sender, state])
func emit_visualize_line(sender: Node, point: Vector3) -> void: emit([sender, point])
func emit_visualize_vector(sender: Node, vector: Vector2) -> void: emit([sender, vector])
