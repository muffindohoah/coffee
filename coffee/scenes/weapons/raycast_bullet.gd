extends RayCast2D

@export var damage := 1
@export var max_range := 500.0
@export var color := Color.WHITE
@export var attacker: CharacterBody2D = null

func _ready() -> void:
	$Line2D.set_point_position(1, Vector2(max_range, 0))
	target_position = Vector2(max_range, 0)
	force_raycast_update()
	if is_colliding():
		var c := get_collider() as Node2D
		var dist := global_position.distance_to(get_collision_point())
		$Line2D.set_point_position(1, Vector2(dist, 0))
		if c.is_in_group("damageable"):
			c.hit(attacker, damage)
			if c.is_in_group("enemy"):
				c.velocity += (c.global_position - global_position).normalized() * 500
	queue_redraw()

func _on_ttl_timeout() -> void:
	queue_free()
