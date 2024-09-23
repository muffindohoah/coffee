extends Node

var ammo0 = 3 #0 is shotgun, 1 is fire, 2 is chain
var ammo1 = 3
var ammo2 = 3
var current_ammo = 1

signal ammo_switched()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ammo_switch():
	current_ammo += 1
	current_ammo = current_ammo % 3
	print(current_ammo)
	ammo_switched.emit()
