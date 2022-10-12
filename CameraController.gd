extends Node3D

enum CAMERA_PIVOT { OVER_SHOULDER, THIRD_PERSON }

@export_node_path var player_path : NodePath
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 8.0) var joystick_sensitivity := 2.0
@export var tilt_upper_limit := deg_to_rad(-60.0)
@export var tilt_lower_limit := deg_to_rad(60.0)

@onready var over_shoulder_pivot: Node3D = $CameraOverShoulderPivot
@onready var third_person_pivot: Node3D = $CameraSpringArm/CameraThirdPersonPivot
@onready var camera: Camera3D = $PlayerCamera

var pivot: Node3D
var _rotation_input: float
var _tilt_input: float
var _mouse_input := false
var _offset: Vector3
var _anchor: Node3D

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity


func _process(delta: float) -> void:
	if not _anchor:
		return
	
	global_transform.origin = _anchor.global_transform.origin + _offset
	camera.global_transform = camera.global_transform.interpolate_with(pivot.global_transform, 0.1)
	
	_rotation_input += Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
	_tilt_input += Input.get_action_strength("camera_up") - Input.get_action_strength("camera_down")

	if not _mouse_input:
		_rotation_input *= joystick_sensitivity
		_tilt_input *= joystick_sensitivity
	
	transform = transform.rotated(Vector3.UP, _rotation_input * delta)
	transform = transform.rotated((transform * Vector3.RIGHT).normalized(), _tilt_input * delta)
#	rotate_y(_rotation_input * delta)
#	rotate_x(_tilt_input * delta)
#	transform.
#	rotation.x = clamp(rotation.x, tilt_upper_limit, tilt_lower_limit)

	_rotation_input = 0.0
	_tilt_input = 0.0


func setup(anchor: Node3D) -> void:
	top_level = true
	_anchor = anchor
	_offset = global_transform.origin - anchor.global_transform.origin
	set_pivot(CAMERA_PIVOT.THIRD_PERSON)
	camera.global_transform = camera.global_transform.interpolate_with(pivot.global_transform, 0.1)


func set_pivot(pivot_type: CAMERA_PIVOT) -> void:
	match(pivot_type):
		CAMERA_PIVOT.OVER_SHOULDER:
			pivot = over_shoulder_pivot
		CAMERA_PIVOT.THIRD_PERSON:
			pivot = third_person_pivot
