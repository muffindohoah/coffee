extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var targets = []

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if !targets.is_empty():
		
		velocity.x = move_toward(velocity.x, targets[0].position.x, SPEED)

	move_and_slide()


func _on_detectionrange_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		targets.append(area.get_parent())
