extends Node3D

@export var camera_speed := 10
@export var mouse_sensitivity := 0.01

@onready var camera: Camera3D
@onready var _cached_camera: Camera3D
@onready var _enabled := false


func _ready() -> void:
	if OS.is_debug_build():
		_enabled = true
	set_process(_enabled)
	set_process_input(_enabled)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_F10:
				_toggle_camera_mode()


func _process(delta: float) -> void:
	if not visible:
		return
	
	var movement := Vector3.ZERO
	movement += Vector3.FORWARD if Input.is_key_pressed(KEY_W) else Vector3.ZERO
	movement += Vector3.LEFT if Input.is_key_pressed(KEY_A) else Vector3.ZERO
	movement += Vector3.BACK if Input.is_key_pressed(KEY_S) else Vector3.ZERO
	movement += Vector3.RIGHT if Input.is_key_pressed(KEY_D) else Vector3.ZERO
	movement += Vector3.DOWN if Input.is_key_pressed(KEY_Q) else Vector3.ZERO
	movement += Vector3.UP if Input.is_key_pressed(KEY_E) else Vector3.ZERO
	
	var rotation_input = -Input.get_last_mouse_velocity().x * mouse_sensitivity
	var tilt_input = -Input.get_last_mouse_velocity().y * mouse_sensitivity
	
	var euler_rotation = camera.global_transform.basis.get_euler()
	euler_rotation.x += tilt_input * delta
	euler_rotation.x = clamp(euler_rotation.x, -PI + 0.01, PI - 0.01)
	euler_rotation.y += rotation_input * delta
	camera.global_transform.basis = Basis.from_euler(euler_rotation)
	
	camera.global_position += camera.global_transform.basis * movement * delta * camera_speed


func _toggle_camera_mode() -> void:
	if visible:
		get_tree().paused = false
		_cached_camera.current = true
		camera.queue_free()
		hide()
		
		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.show()
	else:
		get_tree().paused = true
		_cached_camera = get_viewport().get_camera_3d()
		camera = Camera3D.new()
		add_child(camera)
		camera.current = true
		show()
		camera.fov = _cached_camera.fov
		camera.global_transform = _cached_camera.global_transform
		
		for node in get_tree().get_nodes_in_group("camera_mode_toggle"):
			node.hide()
