extends CanvasLayer

@onready var rotating_mesh = $SubViewport.rotating_mesh
@onready var remaining_ammo_label = $Panel/ammolabel
@onready var ammo_type_label = $Panel/ammotypelabel

var selected_ammo_remaining
var selected_ammo

const ammo_type_label_DB = ["BLAST","FIRE","CHAIN"]

func _ready() -> void:
	Utils.ammo_switched.connect(_on_ammo_switched)

func _on_ammo_switched():
	set_ammo_type(Utils.current_ammo)

func set_ammo_type(type):
	rotating_mesh.change_ammo_to(type)
	remaining_ammo_label.text = str(Utils.get("ammo%s" % type))
	ammo_type_label.text = ammo_type_label_DB[type]
