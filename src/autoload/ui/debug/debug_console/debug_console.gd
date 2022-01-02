extends RichTextLabel

@export var buffer_size_lines: int = 25

@onready var rotation_queue: DataStructures.RotationQueue = DataStructures.RotationQueue.new(buffer_size_lines)


func _ready() -> void:
	Signals.debug_write.connect(self._on_debug_write)
	assert(rotation_queue != null, Errors.NULL_NODE)


func _on_debug_write(sender: Node, variant: Variant) -> void:
	var string: String = str(variant)
	var hex_color: String = CColor.str_to_color(sender.name).to_html(false)
	rotation_queue.add("[color=#%s][code][%s]:[/code][/color] %s" % [hex_color, sender.name, string])
	var lines: Array[String] = []
	lines.resize(rotation_queue.size())
	for i_line in range(rotation_queue.size()):
		lines[i_line] = rotation_queue.get_item(i_line)
	text = "\n".join(lines)
	visible = true
