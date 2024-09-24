extends Node3D

@export_flags_3d_physics var fragment_collision_layer:int = 1
@export_flags_3d_physics var fragment_collision_mask:int = 1
@export var explosion_speed:float = 4
@export var min_frag_lifetime:float = 1.2
@export var max_frag_lifetime:float = 1.8

func _ready() -> void:
	$mugOG.visible = true

func _process(delta: float) -> void:
	pass

func explode():
	$mugOG.visible = false
	$"mug-shatter".visible = true
	
	var parent = get_parent()
	queue_free()
	
	for child in $"mug-shatter".get_children():
		if child is MeshInstance3D:
			child.visible = true
			
			var frag = preload("res://blends/fragment.tscn").instantiate()
			frag.inst_from_mesh(child)
			frag.collision_layer = fragment_collision_layer
			frag.collision_mask = fragment_collision_mask
			#parent.
			parent.add_child(frag)
			
			var vel = (frag.global_transform.origin - $"mug-shatter/explodeorigin".global_transform.origin) * explosion_speed
			if explosion_speed == 0:
				vel = Vector3(0,0,0)
			frag.linear_velocity = vel
			
			frag.lifetime = randf_range(min_frag_lifetime*1000, max_frag_lifetime*1000)
