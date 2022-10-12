class_name CameraController
extends Node3D

enum CAMERA_PIVOT { OVER_SHOULDER, THIRD_PERSON }

@export_node_path var player_path : NodePath
@export var invert_mouse_y := false
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 8.0) var joystick_sensitivity := 2.0
@export var tilt_upper_limit := deg_to_rad(-60.0)
@export var tilt_lower_limit := deg_to_rad(60.0)

@onready var over_shoulder_pivot: Node3D = $CameraOverShoulderPivot
@onready var third_person_pivot: Node3D = $CameraSpringArm/CameraThirdPersonPivot
@onready var camera: Camera3D = $PlayerCamera

var _pivot: Node3D
var _rotation_input: float
var _tilt_input: float
var _mouse_input := false
var _offset: Vector3
var _anchor: Node3D
var _euler_rotation: Vector3

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity
		if invert_mouse_y:
			_tilt_input *= -1


func _process(delta: float) -> void:
	if not _anchor:
		return
	
	# Set camera controller to current ground level for the character
	var target_position = _anchor.global_position + _offset
	target_position.y = _anchor._ground_height
	global_position = target_position
	
	# Rotates camera using euler rotation
	_euler_rotation.x += _tilt_input * delta
	_euler_rotation.x = clamp(_euler_rotation.x, tilt_lower_limit, tilt_upper_limit)
	_euler_rotation.y += _rotation_input * delta
	transform.basis = transform.basis.from_euler(_euler_rotation)
	
	camera.global_transform = camera.global_transform.interpolate_with(_pivot.global_transform, 0.5)

	_rotation_input = 0.0
	_tilt_input = 0.0


func setup(anchor: Node3D) -> void:
	top_level = true
	camera.top_level = true
	
	_anchor = anchor
	_offset = global_transform.origin - anchor.global_transform.origin
	set_pivot(CAMERA_PIVOT.THIRD_PERSON)
	camera.global_transform = camera.global_transform.interpolate_with(_pivot.global_transform, 0.1)


func set_pivot(pivot_type: CAMERA_PIVOT) -> void:
	match(pivot_type):
		CAMERA_PIVOT.OVER_SHOULDER:
			_pivot = over_shoulder_pivot
		CAMERA_PIVOT.THIRD_PERSON:
			_pivot = third_person_pivot
