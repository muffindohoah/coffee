extends Node3D

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	select_level("country")
	select_level("residential")
	select_level("industrial")
	select_level("corporate")
	Utils.load_scene("res://scenes/levels/test_level.tscn")

func select_level(level):
	anim_player.queue(level)
	#anim_player.play(str(level))
