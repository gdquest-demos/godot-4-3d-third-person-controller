class_name Player
extends CharacterBody3D

const PROJECTILE_SCENE = preload("res://Player/Projectile.tscn")

@export var move_speed := 8.0
@export var projectile_speed := 50
@export var attack_impulse := 10
@export var acceleration := 4.0
@export var jump_initial_impulse := 12.0
@export var jump_additional_force := 4.5
@export var rotation_speed := 12.0
@export var snap_length := 0.5

var _move_direction := Vector3.ZERO
var _last_strong_direction := Vector3.FORWARD
var _snap := Vector3.DOWN * snap_length
var _gravity: float = -30.0
var _ground_height: float = 0.0

@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: Node3D = $CameraController
@onready var _attack_animation_player: AnimationPlayer = $CharacterRotationRoot/MeleeAnchor/AnimationPlayer
@onready var _aim_recticle: ColorRect = $AimRecticle
@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
@onready var _start_position := global_transform.origin


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_camera_controller.setup(self)


func _physics_process(delta: float) -> void:
	# Calculate ground height for camera controller
	for collision_result in _ground_shapecast.collision_result:
		_ground_height = max(_ground_height, collision_result.point.y)
	if global_position.y < _ground_height:
		_ground_height = global_position.y

	var is_just_attacking := Input.is_action_just_pressed("attack") and not _attack_animation_player.is_playing()
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_aiming := Input.is_action_pressed("aim") and is_on_floor()
	var is_air_boosting := Input.is_action_pressed("jump") and not is_on_floor() and velocity.y > 0.0
	var is_landing := _snap == Vector3.ZERO and is_on_floor()

	_move_direction = _get_camera_oriented_input()

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	if is_aiming:
		_last_strong_direction = _camera_controller.global_transform.basis * Vector3.BACK
	
	_aim_recticle.visible = is_aiming
	_orient_character_to_direction(_last_strong_direction, delta)

	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity

	if is_aiming:
		_camera_controller.set_pivot(_camera_controller.CAMERA_PIVOT.OVER_SHOULDER)
	else:
		_camera_controller.set_pivot(_camera_controller.CAMERA_PIVOT.THIRD_PERSON)
	
	if is_just_attacking:
		if is_aiming:
			if is_on_floor():
				shoot()
		else:
			attack()
	else:
		velocity.y += _gravity * delta

	if is_just_jumping:
		velocity.y = jump_initial_impulse
		_snap = Vector3.ZERO
	elif is_air_boosting:
		velocity.y += jump_additional_force * delta
	elif is_landing:
		_snap = Vector3.DOWN * snap_length
	move_and_slide()


func _get_camera_oriented_input() -> Vector3:
	if _attack_animation_player.is_playing():
		return Vector3.ZERO
	
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
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var model_scale := _rotation_root.transform.basis.get_scale()
	_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)


func attack() -> void:
	_attack_animation_player.play("Attack")
	velocity = _rotation_root.transform.basis * Vector3.BACK * attack_impulse


func shoot() -> void:
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.shooter = self
	var origin = global_position + Vector3.UP
	var aim_target = _camera_controller.get_aim_target()
	var aim_direction = (aim_target - origin).normalized()
	projectile.velocity = aim_direction * projectile_speed
	get_parent().add_child(projectile)
	projectile.global_position = origin


func reset_position() -> void:
	transform.origin = _start_position
