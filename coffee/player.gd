extends CharacterBody2D

@onready var anim_player = $AnimationPlayer
@onready var dodge_cooldown_timer = $dodgecooldown

const COOLDOWN = 0.5
const ROLL_SPEED = 600
const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var Invulnerable = true
var canAttack = true
var canMove = true

func _ready() -> void:
	dodge_cooldown_timer.wait_time = COOLDOWN

func _physics_process(delta: float) -> void:
	
	if canMove:
		
		_movement_process()
		_input_process()
	
	print(dodge_cooldown_timer.time_left)
	move_and_slide()


func _input_process():
	
	var direction := Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("dodgeparry") && (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		roll(direction)
		
	elif Input.is_action_just_pressed("dodgeparry"):
		parry()

func _movement_process():
	if not is_on_floor():
		velocity.y += 30
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func parry():
	if dodge_cooldown_timer.time_left == 0:
		anim_player.play("parry")
		dodge_cooldown_timer.start()

func roll(direction):
	if dodge_cooldown_timer.time_left == 0:
		canMove = false
		anim_player.play("roll")
		velocity.y += -20
		velocity.x = direction * ROLL_SPEED
		dodge_cooldown_timer.start()

func hurt():
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll":
		canMove = true

func hit(damage: int) -> void:
	pass

func die() -> void:
	queue_free()
