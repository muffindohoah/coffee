extends Node2D

@onready var world: Node2D = get_tree().get_first_node_in_group("world")
@export var wielder: CharacterBody2D = null

const RAYCAST_BULLET := preload("res://scenes/weapons/raycast_bullet.tscn")

func action_primaryfire() -> void:
	print("POW")
	var bulletcount := 5
	var spread := deg_to_rad(15)
	var angle := -spread/2
	for i in range(bulletcount):
		var b := RAYCAST_BULLET.instantiate()
		b.global_position = global_position
		b.global_rotation = global_rotation + angle
		b.attacker = wielder
		world.add_child(b)
		angle += spread/bulletcount
