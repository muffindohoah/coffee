extends Node2D
class_name Flip2D

#calling face with no input will flip
func face(direction: int = 9999) -> void:
	if direction < 0:
		scale.x = -1
	if direction > 0:
		scale.x = 1
	if direction == 9999:
		if scale.x == -1:
			scale.x = 1
		if scale.x == 1:
			scale.x = -1

func is_right():
	var direction
	if scale.x == 1:
		return true
	else:
		return false
