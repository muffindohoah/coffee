extends CharacterBody2D


@export var SPEED = 300.0
@export var ACCELERATION = 500.0
@export var JUMP_VELOCITY = -400.0
@export var INITIAL_HEALTH = 2
@export var BASE_DAMAGE = 1

var knockback: Vector2

var health = INITIAL_HEALTH
var targets: Array[Node2D] = []



func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if !targets.is_empty():
		if is_instance_valid(targets[0]):
			var t := targets[0] # target
			var dir := (t.global_position - global_position).normalized() # vector pointing towards target
			if dir.x < 0:
				velocity.x = move_toward(velocity.x, -SPEED, ACCELERATION * delta)
				$flip2d.face(-1)
			else:
				velocity.x = move_toward(velocity.x, SPEED, ACCELERATION * delta)
				$flip2d.face(1)
		else:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	
	
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	velocity += knockback
	move_and_slide()
	velocity -= knockback

func hit(from:CharacterBody2D, damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_detectionrange_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		targets.append(body)

func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.is_in_group("damageable"):
		body.hit(self, BASE_DAMAGE)
