extends RichTextLabel

@export var lines_to_show: int = 25

var buffer: PackedStringArray = []


func _ready() -> void:
	Signals.debug_write.connect(_on_debug_write)


func _on_debug_write(sender: Node, variant: Variant) -> void:
	var string: String = str(variant)
	var hex_color: String = CColor.str_to_color(sender.name).to_html(false)
	buffer.append("[color=#%s][code][%s]:[/code][/color] %s" % [hex_color, sender.name, string])
	text = "\n".join(buffer.slice(buffer.size() - lines_to_show))
	visible = true
