extends Label


@export var target_path := NodePath()


@onready var target: Node = get_node(target_path)


func _ready():
	Signals.connect(Signals.state_entered.get_name(), self._on_state_entered)
	Signals.connect(Signals.state_exited.get_name(), self._on_state_exited)

	assert(target != null)
	self.text = str(target.name) + " state: (null)"


func _on_state_entered(sender: Node, state_name: String) -> void:
	set("custom_colors/font_color", CColor.str_to_color(state_name))
	if sender.owner == target:
		self.text = str(target.name) + " state: " + state_name


func _on_state_exited(sender: Node, _state_name: String) -> void:
	set("custom_colors/font_color", Color.WHITE)
	if sender.owner == target:
		self.text = str(target.name) + " state: (null)"
