extends StaticBody3D

@export var bounce_height: float = 2.5
@export var color_bounce: Color = Color(1.0, 1.0, 1.0)
@export var color_tween_duration: float = 0.5
@export var _sfx_resource: Resource

var tween: Tween

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var bounce_speed: float = 2.0 * sqrt(gravity * bounce_height)
@onready var mesh_instance: MeshInstance3D = get_node("PhysicsStepInterpolator/BounceMesh") as MeshInstance3D
@onready var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0) as StandardMaterial3D
@onready var color_default: Color = material.albedo_color
@onready var sfx_resource: SfxResource = _sfx_resource as SfxResource


func _ready() -> void:
	assert(mesh_instance != null, Errors.NULL_NODE)
	assert(material != null, Errors.NULL_RESOURCE)
	assert(sfx_resource != null, Errors.NULL_RESOURCE)


func _on_body_entered(body: Node3D) -> void:
	if basis.y.dot(Vector3.UP) > 0.0:
		var rigid_body: RigidDynamicBody3D = body as RigidDynamicBody3D
		if rigid_body != null:
			var impulse: Vector3 = body.mass * (bounce_speed - rigid_body.linear_velocity.y) * Vector3.UP
			rigid_body.apply_central_impulse(impulse)
			Signals.emit_body_bounced(self, body)

			material.albedo_color = color_bounce
			if tween != null:
				tween.kill()
			tween = create_tween()
			tween.set_trans(Tween.TRANS_QUINT)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(material, "albedo_color", color_default, color_tween_duration)

			Signals.emit_request_sfx_play(self, sfx_resource, global_position)
