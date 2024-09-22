extends Node2D
class_name Flip2D

func face(direction: int) -> void:
	if direction < 0:
		scale.x = -1
	if direction > 0:
		scale.x = 1
