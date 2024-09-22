extends CharacterBody2D

@onready var anim_player := $AnimationPlayer
@onready var dodge_cooldown_timer := $dodgecooldown
@onready var counter_pivotpoint = $counterpivotpoint
@onready var counter_hitbox = $counterpivotpoint/counter_hitbox
@onready var slice_hitbox = $flip2d/slice_hitbox

const COOLDOWN := 0.5
const ROLL_SPEED := 1000
const SPEED := 500.0
const GRAVITY := 5000.0
const JUMP_SPEED := 0.3 * GRAVITY# + 1000.0
const BASE_DAMAGE := 1
const INITIAL_HEALTH := 3

var health = INITIAL_HEALTH
var knockback := Vector2.ZERO

var isinvulnerable := true
var canattack := true
var canmove := true
var doesgravity := true

func _ready() -> void:
	dodge_cooldown_timer.wait_time = COOLDOWN
	counter_hitbox.monitoring = false
	slice_hitbox.monitoring = false

func _process(delta: float) -> void:
	$Line2D.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	
	
	if canmove:
		_movement_process(delta)
		_input_process(delta)
	
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	
	velocity += knockback
	move_and_slide()
	velocity -= knockback # silly way of doing this


func _input_process(delta: float):
	
	var direction := Input.get_axis("left", "right")
	
	if canattack:
		if Input.is_action_just_pressed("melee"):
			slice()
	
	if dodge_cooldown_timer.time_left <= 0:
		if Input.is_action_just_pressed("dodgeparry") && (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			roll(direction)
			
		elif Input.is_action_just_pressed("dodgeparry"):
			parry()

func _movement_process(delta: float):
	if doesgravity:
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
	
	isinvulnerable = true
	doesgravity = false
	anim_player.play("parry")
	dodge_cooldown_timer.start()

func counter(enemy):
	anim_player.pause()
	counter_pivotpoint.look_at(enemy.position)
	counter_hitbox.monitoring = true
	anim_player.play()
	#dodge_cooldown_timer.stop()
	#dodge_cooldown_timer.start(0)
	self.knockback += Vector2(
			sign(self.global_position.x - enemy.global_position.x) * 1000,
			-1000
		)


func roll(direction):
	slice_hitbox.monitoring = false
	
	
	set_collision_mask_value(5, false)
	canmove = false
	anim_player.play("roll")
	velocity.y += -20
	velocity.x = direction * ROLL_SPEED
	dodge_cooldown_timer.start()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll":
		canmove = true
		set_collision_mask_value(5, true)
	if anim_name == "parry":
		isinvulnerable = false
		doesgravity = true
		counter_hitbox.monitoring = false
		counter_hitbox.monitorable = false

func hit(from: CharacterBody2D, damage: int) -> void:
	if anim_player.current_animation == "parry":
		counter(from)
	elif anim_player.current_animation == "roll":
		print("rollthrough")
	else:
		health -= damage
		self.knockback += Vector2(
			sign(self.global_position.x - from.global_position.x) * 1000,
			-500
		)

func die() -> void:
	queue_free()

func _on_counter_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable"):
		body.hit(self, BASE_DAMAGE)

func slice():
	anim_player.play("slice")

func _on_slice_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable"):
		body.hit(self, BASE_DAMAGE)
		body.knockback += Vector2(
			sign(body.global_position.x - global_position.x) * 400,
			-300
		)
