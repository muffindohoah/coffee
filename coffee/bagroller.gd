extends MeshInstance3D

var target_rotation = 90

const BAG_ROTATIONS = [0, 130, 260] #0 is shotgun, 130 is fire, 260 is chain
#these rotation values are fuck, i dont know what the real ones are. have to find out.
#also clamp them somehow so they dont fly around. the bags.

func _physics_process(delta: float) -> void:
	rotation_degrees.x = lerp(rotation_degrees.x, float(target_rotation), 0.05)

func change_ammo_to(type):
	target_rotation = BAG_ROTATIONS[type]

func rotate_wheel(amount):
	target_rotation = target_rotation + (120 * amount)
