extends TextEdit

@export var buffer_size_lines: int = 25

@onready var rotationQueue: DataStructures.RotationQueue = DataStructures.RotationQueue.new(buffer_size_lines)


func _ready():
	Signals.connect(Signals.debug_write.get_name(), self._on_debug_write)
	assert(rotationQueue != null)


func _on_debug_write(sender: Node, string: String):
	visible = true
	rotationQueue.add("[%s]: %s" % [sender.name, string])
	var lines: Array[String]
	lines.resize(rotationQueue.size())
	for iLine in range(rotationQueue.size()):
		lines[iLine] = rotationQueue.get_item(iLine)
	text = "\n".join(lines)
	set_v_scroll(INF)
