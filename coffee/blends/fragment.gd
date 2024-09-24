extends RigidBody3D
class_name fragment

@export var lifetime:float = 1
var elapsed_time:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += 1
	if elapsed_time > lifetime:
		queue_free()
	

func inst_from_mesh(source:MeshInstance3D):
	global_transform = source.global_transform
	
	var mesh_inst = source.duplicate()
	mesh_inst.transform = Transform3D.IDENTITY
	add_child(mesh_inst)
	
	$CollisionShape3D.shape = source.mesh.create_convex_shape()
