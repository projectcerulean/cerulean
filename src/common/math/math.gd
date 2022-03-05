class_name Math
extends Node


static func signed_sqrt(x: float) -> float:
	return sign(x) * sqrt(abs(x))


static func ellipse(radii: Vector2, theta: float):
	return radii.x * radii.y / sqrt((radii.y * cos(theta)) * (radii.y * cos(theta)) + (radii.x * sin(theta)) * (radii.x * sin(theta)))
