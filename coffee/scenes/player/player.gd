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
const JUMP_SPEED := 0.3 * GRAVITY# + 1000.0 <-- ??? <--- idk
const BASE_DAMAGE := 1
const INITIAL_HEALTH := 3

var health = INITIAL_HEALTH
var movementvelocity := Vector2.ZERO

enum State {
	IDLE,
	WALK, #attacking, aiming, misc
	RUN,
	AIR, # falling
	DASH,
	MELEE,
	RANGED, # gun
	COUNTER,
}
var state := State.IDLE

var status_takesdamage    := true
var status_takesknockback := true
var status_hasgravity     := true
var status_canmove        := true
var status_canjump        := true
var status_candodge       := true
var status_canattack      := true
func status_lockactions():
	status_canmove = false
	status_canjump = false
	status_candodge = false
	status_canattack = false

func state_change(from: State, to: State):
	print("[%s] state %s" % [name, State.keys()[to]])
	
	status_takesdamage    = true
	status_takesknockback = true
	status_hasgravity     = true
	status_canmove        = true
	status_canjump        = true
	status_candodge       = true
	status_canattack      = true
	
	if to == State.IDLE:
		anim_player.play("idle")
	
	elif to == State.WALK:
		pass
	
	elif to == State.RUN:
		anim_player.play("idle") # TODO
	
	elif to == State.AIR:
		anim_player.play("idle") # TODO
	
	elif to == State.DASH:
		status_takesknockback = false
		status_takesdamage = false
		status_hasgravity  = false
		status_lockactions()
		var direction = Input.get_axis("left", "right")
		action_dash(direction)
	
	elif to == State.MELEE:
		status_takesdamage    = false
		status_takesknockback = false
		status_hasgravity     = false # cool factor; based
		status_lockactions()
		action_slice()
	
	elif to == State.RANGED:
		status_takesdamage    = false
		status_takesknockback = false
		status_lockactions()
		action_shoot()
	
	elif to == State.COUNTER:
		status_takesdamage    = false
		status_takesknockback = false
		status_hasgravity     = false # cool factor
		status_lockactions()
		action_counter()
	
	state = to

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "idle": # IDLE state
		pass
	elif anim_name == "idle": # RUN (TODO)
		pass
	elif anim_name == "idle": # AIR (TODO)
		pass
	elif anim_name == "roll": # DASH (TODO)
		set_collision_mask_value(3, true)
		state_change(state, State.IDLE)
	elif anim_name == "slice": # MELEE
		state_change(state, State.IDLE)
	elif anim_name == "idle": # RANGED (TODO)
		pass
	elif anim_name == "parry": # COUNTER
		state_change(state, State.IDLE)
	#anim_player.play("idle")

func _ready() -> void:
	dodge_cooldown_timer.wait_time = COOLDOWN
	state_change(State.IDLE, State.IDLE)

func _process(delta: float) -> void:
	$weaponpivot.look_at(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	
	$healthLabel.text = str(health)
	
	var direction := Input.get_axis("left", "right")
	
	if status_hasgravity and not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if status_canjump and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= JUMP_SPEED
	
	if ammo_switch_cooldown.time_left == 0 and Input.is_action_just_pressed("changeammo"):
		Utils.ammo_switch()
		ammo_switch_cooldown.start()
	
	if status_canattack and Input.is_action_just_pressed("changeammo"):
		action_ammo_switch()
	
	if status_canattack and Input.is_action_just_pressed("melee"):
		state_change(state, State.MELEE)
	
	if status_canattack and Input.is_action_just_pressed("shoot"):
		state_change(state, State.RANGED)
	
	if status_candodge and Input.is_action_just_pressed("dodgeparry"):
		if direction:
			state_change(state, State.DASH)
		else:
			state_change(state, State.COUNTER)
	
	if status_canmove:
		if direction < 0: movementvelocity.x = -SPEED
		if direction > 0: movementvelocity.x = SPEED
		if direction == 0: movementvelocity.x = 0
		
		
		
		# flip sprites
		if direction < 0: $flip2d.face(-1)
		if direction > 0: $flip2d.face(1)
	else:
		movementvelocity.x = 0
	
	velocity = velocity.move_toward(Vector2.ZERO, 2000 * delta)
	
	velocity += movementvelocity
	move_and_slide()
	velocity -= movementvelocity # silly way of doing this

func action_counter():
	anim_player.play("parry")
	dodge_cooldown_timer.start()

func action_counter_onhit(body): # called when we get hit while in COUNTER state
	print("[%s] attack countered!" % [name])
	counter_pivotpoint.look_at(body.position)
	
	for hb in counter_hitbox.get_overlapping_hurtboxes():
		hb.hit(self, BASE_DAMAGE)
		if is_instance_valid(hb.host):
			hb.knockback(Vector2(
				sign(hb.host.global_position.x - global_position.x) * 1000,
				-500
			))
			if hb.host.is_in_group("enemy"):
				hb.host.state_change(hb.host.state, hb.host.State.IDLE)

func action_dash(direction: int): # -1 for left, 1 for right
	assert(direction != 0)
	set_collision_mask_value(3, false)
	anim_player.play("roll")
	velocity.y += -20
	velocity.x = direction * ROLL_SPEED
	dodge_cooldown_timer.start()

func hit(from, damage: int) -> void:
	if state == State.COUNTER:
		action_counter_onhit(from)
	elif status_takesdamage:
		health -= damage
	else:
		print("[%s] plink!" % [name])

func knockback(velocity: Vector2) -> void:
	if status_takesknockback:
		self.velocity += velocity

func die() -> void:
	queue_free()

func action_slice():
	anim_player.play("slice")
	for hb in slice_hitbox.get_overlapping_hurtboxes():
		hb.hit(self, BASE_DAMAGE)
		if is_instance_valid(hb.host):
			hb.knockback(Vector2(
				sign(hb.host.global_position.x - global_position.x) * 1000,
				-500
			))
	velocity += Vector2($flip2d.scale.x * 500, 0)

func action_ammo_switch():
	Utils.ammo_switch()

func action_shoot():
	anim_player.play("slice") # TODO
	$weaponpivot/Shotgun.action_primaryfire()

func _on_dodgecooldown_timeout() -> void:
	status_candodge = true
