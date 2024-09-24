extends Node3D

var mouse_sensitivity := Vector2(0.001, 0.001)

var cameradistance := 50.0

enum Zones { # placeholder level names?
	NONE,
	A,
	B,
	C,
	D,
}
var selected_zone := Zones.A

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		cameradistance = max(15.0, cameradistance - 5.0)
	if Input.is_action_just_pressed("zoom_out"):
		cameradistance = min(200.0, cameradistance + 5.0)
	$camerapivot/Camera3D.position.z = cameradistance
	
	# limit camera angle (compare vertical axis with camera's backward axis, subtract from 90 degrees to get angle from horizontal)
	var pitch := TAU/4 - (global_basis.y).signed_angle_to($camerapivot.global_basis.z, $camerapivot.global_basis.x)
	# if pitch is > 90 degrees, get how much over and rotate back by that much to compensate
	if pitch > TAU/4:
		var over := pitch - TAU/4
		$camerapivot.rotate_object_local(Vector3.RIGHT, over)
	# if pitch is < 0 degrees, get how much below and rotate up by that much to compensate
	if pitch < 0:
		$camerapivot.rotate_object_local(Vector3.RIGHT, pitch)
	
	# show zone selection indicators
	var indicator_a := $mugcity/selectionarea_zonea/zoneselectionindicator
	var indicator_b := $mugcity/selectionarea_zoneb/zoneselectionindicator
	var indicator_c := $mugcity/selectionarea_zonec/zoneselectionindicator
	var indicator_d := $mugcity/selectionarea_zoned/zoneselectionindicator
	indicator_a.visible = false
	indicator_b.visible = false
	indicator_c.visible = false
	indicator_d.visible = false
	if selected_zone == Zones.A:
		indicator_a.visible = true
	elif selected_zone == Zones.B:
		indicator_b.visible = true
	elif selected_zone == Zones.C:
		indicator_c.visible = true
	elif selected_zone == Zones.D:
		indicator_d.visible = true

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	var e := event as InputEventMouseMotion
	var dx := e.relative.x
	var dy := e.relative.y
	$camerapivot.rotate_y(-dx * mouse_sensitivity.x * TAU)
	$camerapivot.rotate_object_local(Vector3.RIGHT, -dy * mouse_sensitivity.y * TAU)

func _physics_process(delta: float) -> void:
	selected_zone = Zones.NONE
	var selector: RayCast3D = $camerapivot/Camera3D/selector
	if selector.is_colliding():
		if selector.get_collider() == $mugcity/selectionarea_zonea:
			selected_zone = Zones.A
		elif selector.get_collider() == $mugcity/selectionarea_zoneb:
			selected_zone = Zones.B
		elif selector.get_collider() == $mugcity/selectionarea_zonec:
			selected_zone = Zones.C
		elif selector.get_collider() == $mugcity/selectionarea_zoned:
			selected_zone = Zones.D
