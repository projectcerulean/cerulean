extends ColorRect

@export var fade_duration: float = 1.0
@export var game_state_resource: Resource

var scene_path_next: String

@onready var tween: Tween = create_tween()


func _ready() -> void:
	Signals.request_scene_transition_start.connect(self._on_request_scene_transition_start)
	Signals.state_entered.connect(self._on_state_entered)
	Signals.scene_changed.connect(self._on_scene_changed)
	assert(game_state_resource as StateResource != null, Errors.NULL_RESOURCE)


func _on_request_scene_transition_start(_sender: Node, scene_path: String, transition_color: Color, duration: float):
	scene_path_next = scene_path
	transition_color.a = 0.0
	color = transition_color
	fade_duration = duration


func _on_state_entered(sender: Node, state: Node) -> void:
	if sender == game_state_resource.state_machine and state == game_state_resource.states.SCENETRANSITION:
		self.visible = true
		tween.kill()
		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(set_alpha, 0.0, 1.0, fade_duration)
		tween.tween_callback(_on_fade_out_finished)


func _on_fade_out_finished() -> void:
	Signals.emit_request_scene_change(self, scene_path_next)


func _on_scene_changed(sender: Node):
	if game_state_resource.current_state == game_state_resource.states.SCENETRANSITION:
		tween.kill()
		tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_trans(Tween.TRANS_QUINT)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_method(set_alpha, 1.0, 0.0, fade_duration)
		tween.tween_callback(_on_fade_in_finished)
		Signals.emit_request_scene_transition_finish(self)


func _on_fade_in_finished() -> void:
	self.visible = false


func set_alpha(alpha: float) -> void:
	color.a = alpha