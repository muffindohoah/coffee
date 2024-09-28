extends CharacterBody2D

@export var ROAMING_SPEED = 100.0
@export var SPEED = 300.0
@export var ACCELERATION = 500.0
@export var INITIAL_HEALTH = 2
const GRAVITY := 5000.0

var movementvelocity := Vector2.ZERO

var health = INITIAL_HEALTH
var targets: Array[Node2D] = []

enum State {
	IDLE,
	ATTACK,
	DEAD,
}
var state := State.IDLE

var status_canmove = true

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
		spawn_pot()
		if is_instance_valid($playersensor.get_collider()):
			if $playersensor.get_collider().is_in_group("player"):
				print(status_canmove)
				
				action_attack()
				
			else:
				$AnimationPlayer.play("raise")
				state_change(state, State.IDLE)

func spawn_pot():
	print("spawn pot")
	var pot_instance = load("res://scenes/enemies/pot.tscn").instantiate()
	pot_instance.position = Vector2(self.position.x + 40, self.position.y)
	get_parent().add_child(pot_instance)

func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# move toward player
	if status_canmove and $playersensor.is_colliding():
		if is_instance_valid($playersensor.get_collider()):
			
			if $playersensor.get_collider().is_in_group("player"):
				status_canmove = false
				state_change(state, State.ATTACK)
			else:
				_roam_process(delta)
				
		else:
			_roam_process(delta)
	else:
		movementvelocity.x = move_toward(movementvelocity.x, 0, ACCELERATION)

	
	velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	velocity += movementvelocity
	move_and_slide()
	velocity -= movementvelocity

func _roam_process(delta):
	if status_canmove:
		if $flip2d.is_right():
			movementvelocity.x = move_toward(movementvelocity.x, ROAMING_SPEED, ACCELERATION)
		else:
			movementvelocity.x = -move_toward(movementvelocity.x, ROAMING_SPEED, ACCELERATION)
	
	if $flip2d/walldetection.get_overlapping_bodies():
		for body in $flip2d/walldetection.get_overlapping_bodies():
			if body.get_class() == "StaticBody2D":
				$flip2d.face()

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
