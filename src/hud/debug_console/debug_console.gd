extends TextEdit

@export var buffer_size_lines: int = 25

var contents: Array[String]
var index_current: int = 0
var n_lines_current: int = 0


func _ready():
	Signals.connect(Signals.debug_write.get_name(), self._on_debug_write)
	contents.resize(buffer_size_lines)


func _on_debug_write(sender: Node, string: String):
	visible = true
	contents[index_current] = "[%s]: %s" % [sender.name, string]
	index_current = (index_current + 1) % buffer_size_lines
	if n_lines_current == buffer_size_lines:
		if index_current == 0:
			text = "\n".join(contents.slice(index_current, buffer_size_lines - 1))
		else:
			text = "\n".join(contents.slice(index_current, buffer_size_lines - 1) + contents.slice(0, index_current - 1))
	else:
		text = "\n".join(contents.slice(0, n_lines_current))
		n_lines_current += 1
	set_v_scroll(INF)
