extends CharacterBody2D

@onready var anim_player := $AnimationPlayer
@onready var ammo_switch_cooldown := $ammoswitchcooldown
@onready var dodge_cooldown_timer := $dodgecooldown
@onready var counter_pivotpoint = $counterpivotpoint
@onready var counter_hitbox = $counterpivotpoint/counter_hitbox
@onready var slice_hitbox = $flip2d/slice_hitbox

const COOLDOWN := 0.5
const ROLL_SPEED := 800
const SPEED := 400.0
const GRAVITY := 5000.0
const JUMP_SPEED := 0.3 * GRAVITY# + 1000.0
const BASE_DAMAGE := 1
const INITIAL_HEALTH := 3

var health = INITIAL_HEALTH
var movementvelocity := Vector2.ZERO

var isinvulnerable := true
var canattack := true
var candodge := true
var canmove := true
var doesgravity := true

func _ready() -> void:
	dodge_cooldown_timer.wait_time = COOLDOWN
	counter_hitbox.monitoring = false
	slice_hitbox.monitoring = false

func _process(delta: float) -> void:
	$weaponpivot.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	
	
	if canmove:
		_movement_process(delta)
		_input_process(delta)
	
	velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	velocity += movementvelocity
	move_and_slide()
	velocity -= movementvelocity # silly way of doing this


func _input_process(delta: float):
	
	var direction := Input.get_axis("left", "right")
	
	if ammo_switch_cooldown.time_left == 0 and Input.is_action_just_pressed("changeammo"):
		Utils.ammo_switch()
		ammo_switch_cooldown.start()
	
	if canattack and Input.is_action_just_pressed("melee"):
		slice()
	
	if canattack and Input.is_action_just_pressed("shoot"):
		action_shoot()
	
	if candodge and Input.is_action_just_pressed("dodgeparry"):
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			roll(direction)
		else:
			parry()

func _movement_process(delta: float):
	if doesgravity and not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= JUMP_SPEED
	
	var direction := Input.get_axis("left", "right")
	
	if direction < 0: movementvelocity.x = -SPEED
	if direction > 0: movementvelocity.x = SPEED
	if direction == 0: movementvelocity.x = 0
	
	# flip sprites
	if direction < 0: $flip2d.face(-1)
	if direction > 0: $flip2d.face(1)

func parry():
	candodge = false
	isinvulnerable = true
	doesgravity = false
	anim_player.play("parry")
	dodge_cooldown_timer.start()

func counter(enemy):
	anim_player.pause()
	counter_pivotpoint.look_at(enemy.position)
	counter_hitbox.monitoring = true
	anim_player.play()
	candodge = true
	self.velocity += Vector2(
			sign(self.global_position.x - enemy.global_position.x) * 1000,
			-1000
		)

func roll(direction):
	candodge = false
	isinvulnerable = true
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
		isinvulnerable = false
	if anim_name == "parry":
		isinvulnerable = false
		doesgravity = true
		counter_hitbox.monitoring = false
		counter_hitbox.monitorable = false

func hit(from: CharacterBody2D, damage: int) -> void:
	if anim_player.current_animation == "parry":
		counter(from)
	elif isinvulnerable:
		print("plink!")
	else:
		health -= damage

func die() -> void:
	queue_free()

func _on_counter_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable"):
		body.hit(self, BASE_DAMAGE)
		if body.is_in_group("enemy"):
			body.velocity += Vector2(
				sign(body.global_position.x - global_position.x) * 1000,
				-500
			)

func slice():
	anim_player.play("slice")

func action_shoot():
	$weaponpivot/Shotgun.action_primaryfire()

func _on_slice_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable"):
		body.hit(self, BASE_DAMAGE)

func _on_dodgecooldown_timeout() -> void:
	candodge = true
