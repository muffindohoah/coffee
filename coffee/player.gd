extends CharacterBody2D

@onready var anim_player := $AnimationPlayer
@onready var dodge_cooldown_timer := $dodgecooldown

const COOLDOWN := 0.5
const ROLL_SPEED := 1000
const SPEED := 500.0
const GRAVITY := 5000.0
const JUMP_SPEED := 0.3 * GRAVITY# + 1000.0

var knockback := Vector2.ZERO

var isinvulnerable := true
var canattack := true
var canmove := true

func _ready() -> void:
	dodge_cooldown_timer.wait_time = COOLDOWN

func _physics_process(delta: float) -> void:
	
	if canmove:
		_movement_process(delta)
		_input_process(delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	
	velocity += knockback
	move_and_slide()
	velocity -= knockback # silly way of doing this


func _input_process(delta: float):
	
	var direction := Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("dodgeparry") && (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		roll(direction)
		
	elif Input.is_action_just_pressed("dodgeparry"):
		parry()

func _movement_process(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= JUMP_SPEED
	var direction := Input.get_axis("left", "right")
	
	if direction < 0: velocity.x = -SPEED
	if direction > 0: velocity.x = SPEED
	if direction == 0: velocity.x = 0
	
	# flip sprites
	if direction < 0: $flip2d.face(-1)
	if direction > 0: $flip2d.face(1)

func parry():
	if dodge_cooldown_timer.time_left == 0:
		anim_player.play("parry")
		dodge_cooldown_timer.start()

func roll(direction):
	if dodge_cooldown_timer.time_left == 0:
		canmove = false
		anim_player.play("roll")
		velocity.y += -20
		velocity.x = direction * ROLL_SPEED
		dodge_cooldown_timer.start()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll":
		canmove = true

func hit(damage: int) -> void:
	pass

func die() -> void:
	queue_free()
