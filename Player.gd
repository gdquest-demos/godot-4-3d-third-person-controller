extends CharacterBody3D

@export var move_speed := 6.0
@export var acceleration := 4.0
@export var jump_initial_impulse := 12.0
@export var jump_additional_force := 4.5
@export var rotation_speed := 12.0
@export var snap_length := 0.5
@export var do_stop_on_slope := true
@export var has_infinite_inertia := true

var _move_direction := Vector3.ZERO
var _last_strong_direction := Vector3.FORWARD
var _snap := Vector3.DOWN * snap_length
var _gravity: float = -30.0

#@onready var _model: AstronautSkin = $AstronautSkin
@onready var _start_position := global_transform.origin
@onready var _camera_controller: Node3D = $CameraController
#@onready var _animation_player: AnimationPlayer = $AnimationPlayer
#@onready var _hit_box_collision: CollisionShape3D = $AttackHitBox/CollisionShape


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CameraController.setup(self)
#	_model.max_ground_speed = move_speed
#	_model.connect("attack_finished", _hit_box_collision, "set_deferred", ["disabled", true])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				_camera_controller.set_pivot(_camera_controller.CAMERA_PIVOT.OVER_SHOULDER)
			else:
				_camera_controller.set_pivot(_camera_controller.CAMERA_PIVOT.THIRD_PERSON)


func _physics_process(delta: float) -> void:
	_move_direction = _get_camera_oriented_input()

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()

	_orient_character_to_direction(_last_strong_direction, delta)

	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity

	if is_on_floor():
		velocity.y = 0.0
		if is_attacking():
			attack()
#			_hit_box_collision.set_deferred("disabled", [false])
	else:
		velocity.y += _gravity * delta

	if is_jumping():
		velocity.y = jump_initial_impulse
		_snap = Vector3.ZERO
#		_model.jump()
	elif is_air_boosting():
		velocity.y += jump_additional_force * delta
	elif is_landing():
		_snap = Vector3.DOWN * snap_length
#		_model.land()
	
	move_and_slide()
	
#	velocity = move_and_slide(
#		velocity, _snap, Vector3.UP, do_stop_on_slope, 4, deg2rad(45), has_infinite_inertia
#	)
#	_model.velocity = velocity


func _get_camera_oriented_input() -> Vector3:
	var input_left_right := (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	var input_forward_back := (
		Input.get_action_strength("move_down")
		- Input.get_action_strength("move_up")
	)
	var raw_input = Vector2(input_left_right, input_forward_back)

	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = -raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = -raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	input = _camera_controller.global_transform.basis * input
	return input


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	pass
#	var left_axis := Vector3.UP.cross(direction)
#	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quat()
#	var model_scale := _model.transform.basis.get_scale()
#	_model.transform.basis = Basis(_model.transform.basis.get_rotation_quat().slerp(rotation_basis, delta * rotation_speed)).scaled(
#		model_scale
#	)


func take_damage() -> void:
	start_blink(false)

# ANCHOR: attack
func attack() -> void:
	pass
#	_model.attack()
#	_hit_box_collision.set_deferred("disabled", false)
#	yield(_model.anim_player, "animation_finished")
#	_hit_box_collision.set_deferred("disabled", true)
# END: attack


func is_jumping() -> bool:
	return Input.is_action_just_pressed("action_jump") and is_on_floor()


func is_air_boosting() -> bool:
	return Input.is_action_pressed("action_jump") and not is_on_floor() and velocity.y > 0.0


func is_landing() -> bool:
	return _snap == Vector3.ZERO and is_on_floor()


func is_attacking() -> bool:
	return false
#	return Input.is_action_just_pressed("attack") and not _model.is_attacking()


func reset_position() -> void:
	transform.origin = _start_position


func start_blink(loop := false) -> void:
	pass
#	_animation_player.get_animation("blink").set_loop(loop)
#	_animation_player.play("blink")


func stop_blink() -> void:
	pass
#	_animation_player.stop(true)
