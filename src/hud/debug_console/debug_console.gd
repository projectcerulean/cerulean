extends TextEdit


func _ready():
	Signals.connect(Signals.debug_write.get_name(), self._on_debug_write)
	text = ""


func _on_debug_write(sender: Node, string: String):
	visible = true
	if text.length() > 0:
		text = "%s\n[%s]: %s" % [text, sender.name, string]
	else:
		text = "[%s]: %s" % [sender.name, string]
	set_v_scroll(INF)
