## usage:
## - add as child of "host" (e.g. enemy CharacterBody2D).
## - set the exported "host" variable to the host,
##   which will cause hit() and die() to call host.hit() and host.die().
extends Area2D
class_name Hurtbox

@export var host: Node2D = null

func enable():
	monitorable = true

func disable():
	monitorable = false

func hit(from: Node2D, damage: int) -> void:
	if is_instance_valid(host):
		host.hit(from, damage)

func die() -> void:
	if is_instance_valid(host):
		host.die()
