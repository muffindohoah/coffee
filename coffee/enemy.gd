extends CharacterBody2D


const SPEED = 300.0
const ACCELERATION = 500.0
const JUMP_VELOCITY = -400.0

var targets: Array[Node2D] = []

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if !targets.is_empty():
		var t := targets[0] # target
		var dir := (t.global_position - global_position).normalized() # vector pointing towards target
		if dir.x < 0:
			velocity.x = move_toward(velocity.x, -SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, SPEED, ACCELERATION * delta)
	
	move_and_slide()

func hit(damage: int) -> void:
	die()

func die() -> void:
	queue_free()

func _on_detectionrange_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		targets.append(body)
