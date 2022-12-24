@tool
class_name GrenadeLauncher
extends Node3D

const GRENADE_SCENE := preload("res://Player/Grenade.tscn")
const IN_RANGE_COLOR := Color(1.0, 0.64, 0.18)
const OUT_OF_RANGE_COLOR := Color(0.95, 0.0, 0.17)
const ENEMY_AIM_COLOR := Color(1, 0, 0, 0.5)
const SHADER_PARAM_FILL_COLOR := "shader_parameter/fill_color"

@export var camera: Camera3D = null
@export var max_throw_radius := 10.0
@export var min_throw_strength := 4.0
@export var max_throw_strength := 14.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _throw_velocity := Vector3.ZERO

@onready var _aim_sprite: MeshInstance3D = $AimSprite
@onready var _grenade_path: Path3D = $LaunchPoint/Path3D
@onready var _csg_polygon: CSGPolygon3D = $LaunchPoint/Path3D/CSGPolygon3D
@onready var _raycast: RayCast3D = $RayCast3D
@onready var _launch_point: Marker3D = $LaunchPoint


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)

	_aim_sprite.material_override.set(SHADER_PARAM_FILL_COLOR, IN_RANGE_COLOR)
	_csg_polygon.material.set(SHADER_PARAM_FILL_COLOR, IN_RANGE_COLOR)


func _get_configuration_warnings() -> PackedStringArray:
	if camera == null:
		return PackedStringArray(["This node must have a valid reference to a Camera3D node to orient itself with the camera."])
	return PackedStringArray()


func _physics_process(delta: float) -> void:
	if visible:
#		_aim_sprite.rotate_y(PI * delta)
		update_aim()


func throw_grenade() -> bool:
	if not visible:
		return false
	
	var grenade := GRENADE_SCENE.instantiate()
	get_parent().add_child(grenade)
	# Add small vertical correction to avoid spawning the grenade under the floor
	grenade.global_position = _grenade_path.global_position + Vector3.UP * 0.1
	grenade.throw(_throw_velocity)
	return true


func update_aim() -> void:
	var global_camera_look_position := camera.global_position + camera.basis * Vector3.FORWARD * max_throw_radius
	
	_raycast.global_position = _launch_point.global_position
	_raycast.target_position = global_camera_look_position - _raycast.global_position
	_raycast.force_raycast_update()
	
	# TODO: Placing aim reticle on ground: ray aiming down from target position

	# Snap grenade land position to an enemy the player's aiming at, if applicable
	var to_target := _raycast.target_position
	var collider := _raycast.get_collider()
	_aim_sprite.visible = collider != null
	if collider:
		if collider.is_in_group("targeteables"):
			to_target = collider.global_position - _launch_point.global_position
		_aim_sprite.global_position = _launch_point.global_position + to_target
		_aim_sprite.look_at(_launch_point.global_position)

	# Calculate the initial velocity the grenade needs based on where we want it to land and how
	# high the curve should go.
	var peak_height: float = max(to_target.y + 1.0, _launch_point.position.y + 1.0)
	
	var motion_up := peak_height - _launch_point.position.y
	var time_going_up := sqrt(2.0 * motion_up / gravity)
	
	var motion_down := to_target.y - peak_height
	var time_going_down := sqrt(-2.0 * motion_down / gravity)
	
	var time_to_land := time_going_up + time_going_down

	var target_position_xz_plane := Vector3(to_target.x, 0.0, to_target.z)
	var start_position_xz_plane := Vector3(_launch_point.position.x, 0.0, _launch_point.position.z)

	var forward_velocity := (target_position_xz_plane - start_position_xz_plane) / time_to_land
	var velocity_up := sqrt(2.0 * gravity * motion_up)
	
	# Caching the found initial_velocity vector so we can use it on the throw() function
	_throw_velocity = Vector3.UP * velocity_up + forward_velocity

	# Redraw the grenade's motion preview
	_grenade_path.curve.clear_points()
	const TIME_STEP := 0.2
	var time_current := 0.0
	while time_current < time_to_land:
		var point := _throw_velocity * time_current + Vector3.DOWN * gravity * 0.5 * time_current * time_current
		_grenade_path.curve.add_point(point)
		time_current += TIME_STEP
