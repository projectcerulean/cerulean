extends MeshInstance3D

@onready var area3d: Area3D = get_node("Area3D")


func _ready() -> void:
	assert(area3d != null)


func _on_area_entered(area: Area3D) -> void:
	Signals.emit_area_area_entered(area3d, area)


func _on_area_exited(area: Area3D) -> void:
	Signals.emit_area_area_exited(area3d, area)


func _on_body_entered(body: PhysicsBody3D) -> void:
	Signals.emit_area_body_entered(area3d, body)


func _on_body_exited(body: PhysicsBody3D) -> void:
	Signals.emit_area_body_exited(area3d, body)
