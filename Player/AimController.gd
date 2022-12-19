class_name GrenadeAimController
extends Node3D

const GRENADE_SCENE := preload("res://Player/Grenade.tscn")
const IN_RANGE_COLOR := Color(1.0, 0.64, 0.18)
const OUT_OF_RANGE_COLOR := Color(0.95, 0.0, 0.17)
const ENEMY_AIM_COLOR := Color(1, 0, 0, 0.5)
const POINTS_IN_CURVE3D := 15
const SHADER_PARAM_FILL_COLOR := "shader_parameter/fill_color"

@export var max_throw_radius := 10.0
@export var min_throw_strength := 4.0
@export var max_throw_strength := 14.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _aim_sprite: MeshInstance3D = $AimSprite
@onready var _grenade_path: Path3D = $Path3D
@onready var _csg_polygon: CSGPolygon3D = $Path3D/CSGPolygon3D
@onready var _cached_grenade_velocity: Vector3
@onready var _ray_cast: RayCast3D = $RayCast3D


func _physics_process(delta: float) -> void:
	if visible:
		_aim_sprite.rotate_y(PI * delta)


func set_active(active: bool) -> void:
	visible = active


func throw_grenade(_origin: Vector3, player: Node3D) -> bool:
	if not visible:
		return false
	
	var grenade := GRENADE_SCENE.instantiate()
	get_parent().add_child(grenade)
	# Add small vertical correction to avoid spawning the grenade under the floor
	grenade.global_position = _grenade_path.global_position + Vector3.UP * 0.1
	grenade.throw(_cached_grenade_velocity, player, _grenade_path.curve)
	
	return true


func set_aim_position(origin: Vector3, target: Vector3, normal: Vector3, camera_basis: Basis, collider: Object) -> void:
	# Check distance from target and clamp it to max_throw_radius
	var distance := target - origin
	if collider != null and collider.is_in_group("targeteables") and distance.length() < max_throw_radius:
		normal = (origin - collider.global_position).normalized()
		target = collider.global_position
		distance = target - origin
	
	if distance.length() > max_throw_radius:
		normal = (origin - target).normalized()
		_aim_sprite.material_override.set(SHADER_PARAM_FILL_COLOR, OUT_OF_RANGE_COLOR)
		_csg_polygon.material.set(SHADER_PARAM_FILL_COLOR, OUT_OF_RANGE_COLOR)
	else:
		_aim_sprite.material_override.set(SHADER_PARAM_FILL_COLOR, IN_RANGE_COLOR)
		_csg_polygon.material.set(SHADER_PARAM_FILL_COLOR, IN_RANGE_COLOR)
	
	distance = distance.limit_length(max_throw_radius)
	target = origin + distance
	
	# Calculate target sprite position and orientation
	_ray_cast.target_position = distance
	var ray_is_colliding := _ray_cast.is_colliding()
	_aim_sprite.visible = ray_is_colliding
	if ray_is_colliding:
		var collision_point := _ray_cast.get_collision_point()
		var collision_normal := _ray_cast.get_collision_normal()
		_aim_sprite.global_transform.origin = collision_point + collision_normal * 0.01
		_aim_sprite.look_at(collision_point - collision_normal, _aim_sprite.global_transform.basis.y.normalized())

	
	# Set grenade path by predicting its bullet motion
	_grenade_path.global_position = origin
	
	# First, calculate target position and distance. Origin is the player position
	var target_position := target - origin
	var distance_to_target := target_position.length()
	var r1_g_dot := target_position.dot(Vector3.DOWN * gravity)
	
	# initial_velocity is the initial velocity vector we want. We know its
	# minimum length using the following formula, and we clamp
	# it to make better trajectories
	var v0_l := sqrt((distance_to_target * gravity) - r1_g_dot)
	v0_l = clamp(v0_l, min_throw_strength, max_throw_strength)
	
	# Now we calculate the necessary factors to discover initial_velocity
	var gravity_squared := gravity * gravity
	
	var f1 := 2.0 / gravity_squared
	var f2 := v0_l * v0_l
	var f3 := r1_g_dot
	var f4_0 := (v0_l * v0_l) + r1_g_dot
	var f4_1 := f4_0 * f4_0 - (gravity_squared * distance_to_target * distance_to_target)
	
	# If f4_1 is less then 0, then this is an impossible trajectory. But
	# to be sure, we return before using sqrt() in it because Godot crashes
	# when calculating a sqrt() of a negative number.
	if f4_1 < 0.0:
		return
	
	var f4 := sqrt(f4_1)
	
	# Now we calculate the times in which the bullet can hit the target position.
	# time_going_up is when the bullet is going up, time_going_down is when the bullet is going down.
	var time_going_up := f1 * (f2 + f3 + f4)
	var time_going_down := f1 * (f2 + f3 - f4)
	
	var initial_velocity := (target_position / time_going_up) - (Vector3.DOWN * gravity * time_going_up * 0.5)
	
	# We get the Curve3D resource from _grenade_path and update it iterating on the
	# predicted trajectory path for the new points
	var curve := _grenade_path.curve
	curve.clear_points()

	for i in range(POINTS_IN_CURVE3D + 1):
		var t: float = lerp(0.0, time_going_down, float(i)/float(POINTS_IN_CURVE3D))
		var point := (initial_velocity * t) + (Vector3.DOWN * gravity * 0.5 * t * t)
		curve.add_point(point)
	
	# Caching the found initial_velocity vector so we can use it on the throw() function
	_cached_grenade_velocity = initial_velocity
