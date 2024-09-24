extends Control

@onready var shatter_cup = $SubViewport/shatter_cup
@onready var loading_bar = $ProgressBar

var next_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_scene = Utils.next_scene
	ResourceLoader.load_threaded_request(next_scene)
	shatter_cup.explode()

func _process(delta: float) -> void:
	var progress = []
	
	var loader = ResourceLoader.load_threaded_get_status(next_scene, progress)
	loading_bar.value = progress[0]*100
	
	if is_instance_valid(shatter_cup):
		shatter_cup.rotation_degrees.y += 1
	
	if progress[0] == 1:
		
		await get_tree().create_timer(1).timeout
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
