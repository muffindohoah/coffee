extends Node3D

@export var text := "put zone name here"

func _ready() -> void:
	$Label3D.text = text
