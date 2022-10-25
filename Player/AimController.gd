class_name GrenadeAimController
extends Node3D

const GRENADE_SCENE = preload("res://Player/Grenade.tscn")
const SURFACE_AIM_COLOR = Color(1, 1, 1, 0.5)
const ENEMY_AIM_COLOR = Color(1, 0, 0, 0.5)
const POINTS_IN_CURVE3D = 10

@export var max_throw_radius := 11.0
@export var min_throw_strength := 6.0
@export var max_throw_strength := 12.0

@onready var _aim_sprite: MeshInstance3D = $AimSprite
@onready var _grenade_path: Path3D = $Path3D
@onready var _gravity_length: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _cached_grenade_velocity: Vector3


func _physics_process(delta: float) -> void:
	if visible:
		_aim_sprite.rotate_y(PI * delta)


func set_active(active: bool) -> void:
	visible = active


func throw_grenade(origin: Vector3, player: Node3D) -> bool:
	if not visible:
		return false
	
	var grenade = GRENADE_SCENE.instantiate()
	get_parent().add_child(grenade)
	grenade.global_position = _grenade_path.global_position
	grenade.throw(_cached_grenade_velocity, player)
	
	return true


func set_aim_position(origin: Vector3, target: Vector3, normal: Vector3, camera_basis: Basis, collider: Object) -> void:
	# Check distance from target and clamp it to max_throw_radius
	var distance := target - origin
	
	if collider != null and collider.is_in_group("targeteables") and distance.length() < max_throw_radius:
		normal = (origin - collider.global_position).normalized()
		target = collider.global_position
		distance = target - origin
	
	_aim_sprite.visible = distance.length() <= max_throw_radius
	
	distance = distance.limit_length(max_throw_radius)
	target = origin + distance
	
	var trans = transform
	
	# Set target sprite position
	trans.origin = origin + distance + (normal * 0.1)
	
	# Set target sprite orientation
	trans.basis.y = normal
	trans.basis.z = -camera_basis.y
	trans.basis.x = trans.basis.z.cross(trans.basis.y).normalized()
	trans.basis.z = trans.basis.y.cross(trans.basis.x).normalized()
	trans.basis = trans.basis.orthonormalized()
	transform = trans
	
	# Set grenade path by predicting its projectile motion

	_grenade_path.global_position = origin
	
	# First, calculate target position and distance. Origin is the player position
	var r1 := transform.origin - origin
	var r1_l := r1.length()
	var r1_g_dot := r1.dot(Vector3.DOWN * _gravity_length)
	
	# v0 is the initial velocity vector we want. We know its
	# minimum length using the following formulae, and we clamp
	# it to make better trajectories
	var v0_l := sqrt((r1_l * _gravity_length) - r1_g_dot)
	v0_l = clamp(v0_l, min_throw_strength, max_throw_strength)
	
	# Now we calculate the necessary factors to discover v0
	var g := Vector3.DOWN * _gravity_length
	var g_squared = _gravity_length * _gravity_length
	
	var f1 := 2.0/(g_squared)
	var f2 := v0_l * v0_l
	var f3 := r1_g_dot
	var f4_0 := (v0_l * v0_l) + r1_g_dot
	var f4_1 := f4_0 * f4_0 - (g_squared * r1_l * r1_l)
	
	# Is f4_1 is less then 0, then this is an impossible trajectory. But
	# to be sure, we return before using sqrt() in it because Godot crashes
	# when calculating a sqrt() of a negative number.
	if f4_1 < 0:
		return
	
	var f4 := sqrt(f4_1)
	
	# Now we calculate the times in which the projectile can hit the target position.
	# t1 is when the projectile is going up, t2 is when the projectile is going down.
	var t1 := f1 * (f2 + f3 + f4) # Downwards movement
	var t2 := f1 * (f2 + f3 - f4) # Upwards movement
	
	# We finally have v0! We'll use t2 because it makes a more interesting trajectory
	var v0 := (r1/t1) - (g*t1*0.5)
	
	# We get the Curve3D resource from _grenade_path and update it iterating on the
	# predicted trajectory path for the new points
	var curve := _grenade_path.curve
	curve.clear_points()

	for i in range(POINTS_IN_CURVE3D + 1):
		var t: float = lerp(0.0, t2, float(i)/float(POINTS_IN_CURVE3D))
		var point := (v0 * t) + (Vector3.DOWN * _gravity_length * 0.5 * t * t)
		curve.add_point(point)
	
	# Caching the found v0 vector so we can use it on the throw() function
	_cached_grenade_velocity = v0

