extends Node3D

@export var camera_speed := 15.0
@export var mouse_sensitivity := 0.005

var is_active := false

var _camera_photo: Camera3D
var _camera_previous: Camera3D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(OS.is_debug_build())
	set_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F10:
		if event.is_pressed() and not event.is_echo():
			_toggle_camera_mode()


func _process(delta: float) -> void:
	var speed_multiplier := 1.0 + float(Input.is_key_pressed(KEY_SHIFT)) * 3.0
	
	var direction := Vector3.ZERO
	direction += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	direction += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	direction += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	direction += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	direction += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	direction += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO
	
	#TODO: issue, this is past mouse velocity, thereś lag, is it due to it?
	var rotation_input = -Input.get_last_mouse_velocity().x * mouse_sensitivity
	var tilt_input = -Input.get_last_mouse_velocity().y * mouse_sensitivity
	
	var euler_rotation = _camera_photo.global_transform.basis.get_euler()
	euler_rotation.x += tilt_input * delta
	euler_rotation.x = clamp(euler_rotation.x, -PI + 0.01, PI - 0.01)
	euler_rotation.y += rotation_input * delta
	_camera_photo.global_transform.basis = Basis.from_euler(euler_rotation)
	
	_camera_photo.global_position += _camera_photo.global_transform.basis * direction * delta * camera_speed *speed_multiplier


func _toggle_camera_mode() -> void:
	is_active = not is_active
	set_process(is_active)
	get_tree().paused = is_active

	for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
		node.visible = not is_active

	if is_active:
		_camera_previous = get_viewport().get_camera_3d()
		_camera_photo = Camera3D.new()
		add_child(_camera_photo)
		_camera_photo.current = true
		_camera_photo.fov = _camera_previous.fov
		_camera_photo.global_transform = _camera_previous.global_transform

	else:
		_camera_previous.current = true
		_camera_photo.queue_free()
