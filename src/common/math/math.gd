class_name Math
extends Node


static func signed_sqrt(x: float) -> float:
	return sign(x) * sqrt(abs(x))
