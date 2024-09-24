extends MeshInstance3D

var target_rotation = 90

#210-90=120
#360/6=60
const BAG_ROTATIONS = [90, 210, 330] #0 is blast, 1 is fire, 2 is chain
#these rotation values are questionable.
#my dampening solution for angular rotation is questionable.
#this can and should be polished at discretion

func _physics_process(delta: float) -> void:
	rotation_degrees.x = lerp(rotation_degrees.x, float(target_rotation), 0.05)
	#print(get_parent().get_node("CHAIN/RigidBody3D3").position)

func change_ammo_to(type):
	target_rotation = BAG_ROTATIONS[type]

func rotate_wheel(amount):
	target_rotation = target_rotation + (120 * amount)
