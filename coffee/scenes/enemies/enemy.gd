extends CharacterBody2D


@export var SPEED = 500.0
@export var ACCELERATION = 5000.0
@export var JUMP_VELOCITY = -400.0
@export var INITIAL_HEALTH = 2
@export var BASE_DAMAGE = 1
const GRAVITY := 7000.0

var movementvelocity := Vector2.ZERO

var health = INITIAL_HEALTH
var targets: Array[Node2D] = []

enum State {
	IDLE,
	ATTACK,
	DEAD,
}
var state := State.IDLE

var status_canmove := true

func state_change(from: State, to: State):
	print("[%s] state %s" % [name, State.keys()[to]])
	
	status_canmove = true
	
	if to == State.IDLE:
		$AnimationPlayer.play("idle")
	elif to == State.ATTACK:
		action_attack()
	elif to == State.DEAD:
		status_canmove = false
		#$AnimationPlayer.play("die") # TODO
		queue_free()
	
	state = to

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "idle": # IDLE state
		pass
	elif anim_name == "attack": # ATTACK
		hurt_overlapping_hurtboxes()
		state_change(state, State.IDLE)

func hurt_overlapping_hurtboxes():
	for hb in $flip2d/attack.get_overlapping_hurtboxes():
			hb.hit(self, BASE_DAMAGE)
			if is_instance_valid(hb.host):
				hb.knockback(Vector2(
					sign(hb.host.global_position.x - global_position.x) * 800,
					-400
				))

func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# move toward player
	if status_canmove and !targets.is_empty():
		if is_instance_valid(targets[0]):
			var t := targets[0] # target
			var dir := (t.global_position - global_position).normalized() # vector pointing towards target
			if dir.x < 0:
				movementvelocity.x = move_toward(movementvelocity.x, -SPEED, ACCELERATION * delta)
				$flip2d.face(-1)
			else:
				movementvelocity.x = move_toward(movementvelocity.x, SPEED, ACCELERATION * delta)
				$flip2d.face(1)
		else:
			movementvelocity.x = move_toward(movementvelocity.x, 0, ACCELERATION * delta)
	else:
		movementvelocity.x = move_toward(movementvelocity.x, 0, ACCELERATION * 3 * delta)
	
	# attack if close enough
	if !targets.is_empty() and is_instance_valid(targets[0]):
		if state == State.IDLE and global_position.distance_to(targets[0].global_position) < 100:
			state_change(state, State.ATTACK)
	
	
	velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	velocity += movementvelocity
	move_and_slide()
	velocity -= movementvelocity

func hit(from: Node2D, damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func knockback(velocity: Vector2) -> void:
	self.velocity += velocity

func die() -> void:
	state_change(state, State.DEAD)

func action_attack() -> void:
	status_canmove = false
	$AnimationPlayer.play("attack")

func _on_detectionrange_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		targets.append(body)
