extends ColorRect

@export var buffer_size_lines: int = 25

@onready var richTextLabel: RichTextLabel = get_node("RichTextLabel")
@onready var rotationQueue: DataStructures.RotationQueue = DataStructures.RotationQueue.new(buffer_size_lines)


func _ready() -> void:
	SignalsGetter.get_signals().debug_write.connect(self._on_debug_write)
	assert(richTextLabel != null)
	assert(rotationQueue != null)


func _on_debug_write(sender: Node, variant: Variant) -> void:
	var string: String = str(variant)
	var hexColor: String = CColor.str_to_color(sender.name).to_html(false)
	rotationQueue.add("[color=#%s][code][%s]:[/code][/color] %s" % [hexColor, sender.name, string])
	var lines: Array[String] = []
	lines.resize(rotationQueue.size())
	for iLine in range(rotationQueue.size()):
		lines[iLine] = rotationQueue.get_item(iLine)
	richTextLabel.bbcode_text = "\n".join(lines)
	visible = true
