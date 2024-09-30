extends RigidBody2D

const BASE_DAMAGE = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		mass = 10000
		rotation_degrees = 0
		$AnimationPlayer.play("mess")
		lock_rotation = true
		sleeping = true
		set_physics_process(0)
	$Area2D.monitoring = false

func _on_hitbox_hurtbox_entered(hurtbox: Hurtbox) -> void:
	hurtbox.host.hit(self, BASE_DAMAGE)
