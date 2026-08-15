extends Node3D

var _camera_speed := 10
var _mouse_sensitivity := 0.001

var _camera: Camera3D = null
var _cached_camera: Camera3D = null


func _ready() -> void:
	if not OS.is_debug_build():
		free()

	process_mode = PROCESS_MODE_ALWAYS
	set_process(false)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventKey and event.is_pressed()
		and not event.is_echo() and event.keycode == KEY_F10
	):
		_toggle_camera_mode()


func _process(delta: float) -> void:
	var movement := Vector3.ZERO
	movement += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	movement += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	movement += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	movement += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	movement += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	movement += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO

	var rotation_input = -Input.get_last_mouse_velocity().x * _mouse_sensitivity
	var tilt_input = -Input.get_last_mouse_velocity().y * _mouse_sensitivity

	var euler_rotation = _camera.global_transform.basis.get_euler()
	euler_rotation.x += tilt_input * delta
	euler_rotation.x = clamp(euler_rotation.x, -PI + 0.01, PI - 0.01)
	euler_rotation.y += rotation_input * delta
	_camera.global_transform.basis = Basis.from_euler(euler_rotation)

	_camera.global_position += _camera.global_transform.basis * movement * delta * _camera_speed


func _toggle_camera_mode() -> void:
	if is_processing():
		get_tree().paused = false
		set_process(false)

		_cached_camera.current = true
		_camera.queue_free()

		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.show()
	else:
		get_tree().paused = true
		set_process(true)

		_cached_camera = get_viewport().get_camera_3d()
		_camera = Camera3D.new()
		add_child(_camera)
		_camera.current = true
		_camera.fov = _cached_camera.fov
		_camera.global_transform = _cached_camera.global_transform

		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.hide()
