## usage:
## - add as child of "host" (e.g. enemy CharacterBody2D).
## - set the exported "host" variable to the host,
##   which will allow get_overlapping_hurtboxes() to ignore hurtboxes that
##   belong to the same host.
## - call get_overlapping_hurtboxes() to get every overlapping hurtbox.
extends Area2D
class_name Hitbox

@export var host: Node2D = null

func enable():
	monitoring = true

func disable():
	monitoring = false

func get_overlapping_hurtboxes() -> Array[Hurtbox]:
	var result: Array[Hurtbox] = []
	for a in get_overlapping_areas():
		print(a.name)
		if not a is Hurtbox: continue
		if host != null and a.host == host: continue # ignore hurtboxes belonging to the same host
		result.append(a)
	print(result.size())
	return result

signal hurtbox_entered(hurtbox: Hurtbox)

func _ready() -> void:
	assert(host != null)
	area_entered.connect(_on_area_entered) # do this in _ready() so the signals tab in the inspector doesn't get polluted
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		hurtbox_entered.emit(area)
