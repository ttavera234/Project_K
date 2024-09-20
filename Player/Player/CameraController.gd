extends Node3D


@export var cam_v_max: int = 75
@export var cam_v_min: int = -25

var camroot_h: float = 0.0
var camroot_v: float = 0.0

var h_sensitivity: float = 0.01
var v_sensitivity: float = 0.01
var h_acceleration: float = 10.0
var v_acceleration: float = 10.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Updates spring arm position
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camroot_h += -event.relative.x * h_sensitivity
		camroot_v += event.relative.y * v_sensitivity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	camroot_v = clamp(camroot_v, deg_to_rad(cam_v_min), deg_to_rad(cam_v_max))
	$HorizontalCam.rotation.y = lerpf($HorizontalCam.rotation.y, camroot_h, delta * h_acceleration)
	%VerticalCam.rotation.x = lerpf(%VerticalCam.rotation.x, camroot_v, delta * v_acceleration)
