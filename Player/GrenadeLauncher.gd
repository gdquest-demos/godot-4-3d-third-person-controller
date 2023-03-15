class_name GrenadeLauncher
extends Node3D

const GRENADE_SCENE := preload("res://Player/Grenade.tscn")

@export var min_throw_distance := 7.0
@export var max_throw_distance := 16.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var from_look_position := Vector3.ZERO
@onready var throw_direction := Vector3.ZERO

@onready var _snap_mesh: Node3D = %SnapMesh
@onready var _raycast: ShapeCast3D = %ShapeCast3D
@onready var _launch_point: Marker3D = %LaunchPoint
@onready var _trail_mesh_instance: MeshInstance3D = %TrailMeshInstance

var _throw_velocity := Vector3.ZERO
var _time_to_land := 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if visible:
		_update_throw_velocity()
		_draw_throw_path()


func throw_grenade() -> bool:
	if not visible:
		return false

	var grenade: CharacterBody3D = GRENADE_SCENE.instantiate()
	get_parent().add_child(grenade)
	grenade.global_position = _launch_point.global_position
	grenade.throw(_throw_velocity)
	PhysicsServer3D.body_add_collision_exception(get_parent().get_rid(), grenade.get_rid())
	return true


func _update_throw_velocity() -> void:
	var camera := get_viewport().get_camera_3d()
	var up_ratio: float = clamp(max(camera.rotation.x + 0.5, -0.4) * 2, 0.0, 1.0)

	# var throw_direction := camera.quaternion * Vector3.FORWARD
	# If the player's not aiming, the camera's far behind the character, so we increase the ray's
	# length based on how far behind the camera is compared to the character.
	var base_throw_distance: float = lerp(min_throw_distance, max_throw_distance, up_ratio)
	# var camera_forward_distance := camera.global_position.project(throw_direction).distance_to(_launch_point.global_position.project(throw_direction))
	var throw_distance := base_throw_distance #+ camera_forward_distance
	var global_camera_look_position := from_look_position + throw_direction * throw_distance
	_raycast.target_position = global_camera_look_position - _raycast.global_position

	# Snap grenade land position to an enemy the player's aiming at, if applicable
	var to_target := _raycast.target_position
	
	if _raycast.get_collision_count() != 0 :
		var collider := _raycast.get_collider(0)
		var has_target: bool = collider and collider.is_in_group("targeteables")
		_snap_mesh.visible = has_target
		if has_target:
			to_target = collider.global_position - _launch_point.global_position
			_snap_mesh.global_position = _launch_point.global_position + to_target
			_snap_mesh.look_at(_launch_point.global_position)
	else:
		_snap_mesh.visible = false
		

	# Calculate the initial velocity the grenade needs based on where we want it to land and how
	# high the curve should go.
	var peak_height: float = max(to_target.y + 0.25, _launch_point.position.y + 0.25)

	var motion_up := peak_height
	var time_going_up := sqrt(2.0 * motion_up / gravity)

	var motion_down := to_target.y - peak_height
	var time_going_down := sqrt(-2.0 * motion_down / gravity)

	_time_to_land = time_going_up + time_going_down

	var target_position_xz_plane := Vector3(to_target.x, 0.0, to_target.z)
	var start_position_xz_plane := Vector3(_launch_point.position.x, 0.0, _launch_point.position.z)

	var forward_velocity := (target_position_xz_plane - start_position_xz_plane) / _time_to_land
	var velocity_up := sqrt(2.0 * gravity * motion_up)

	# Caching the found initial_velocity vector so we can use it on the throw() function
	_throw_velocity = Vector3.UP * velocity_up + forward_velocity


func _draw_throw_path() -> void:
	const TIME_STEP := 0.05
	const TRAIL_WIDTH := 0.25

	var forward_direction = Vector3(_throw_velocity.x, 0.0, _throw_velocity.z).normalized()
	var left_direction := Vector3.UP.cross(forward_direction)
	var offset_left = left_direction * TRAIL_WIDTH / 2.0
	var offset_right = -left_direction * TRAIL_WIDTH / 2.0

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var end_time := _time_to_land + 0.5
	var point_previous = Vector3.ZERO
	var time_current := 0.0
	# We'll create 2 triangles on each iteration, representing the quad of one
	# section of the path
	while time_current < end_time:
		time_current += TIME_STEP
		var point_current := _throw_velocity * time_current + Vector3.DOWN * gravity * 0.5 * time_current * time_current

		# Our point coordinates are at the center of the path, so we need to calculate vertices
		var trail_point_left_end = point_current + offset_left
		var trail_point_right_end = point_current + offset_right
		var trail_point_left_start = point_previous + offset_left
		var trail_point_right_start = point_previous + offset_right

		# UV position goes from 0 to 1, so we normalize the current iteration
		# to get the progress in the UV texture
		var uv_progress_end = time_current/end_time
		var uv_progress_start = uv_progress_end - (TIME_STEP/end_time)

		# Left side on the UV texture is at the top of the texture
		# (Vector2(0,1), or Vector2.DOWN). Right side on the UV texture is at
		# the bottom.
		var uv_value_right_start = (Vector2.RIGHT * uv_progress_start)
		var uv_value_right_end = (Vector2.RIGHT * uv_progress_end)
		var uv_value_left_start = Vector2.DOWN + uv_value_right_start
		var uv_value_left_end = Vector2.DOWN + uv_value_right_end

		point_previous = point_current

		# Both triangles need to be drawn in the same orientation (Godot uses
		# clockwise orientation to determine the face normal)

		# Draw first triangle
		st.set_uv(uv_value_right_end)
		st.add_vertex(trail_point_right_end)
		st.set_uv(uv_value_left_start)
		st.add_vertex(trail_point_left_start)
		st.set_uv(uv_value_left_end)
		st.add_vertex(trail_point_left_end)

		# Draw second triangle
		st.set_uv(uv_value_right_start)
		st.add_vertex(trail_point_right_start)
		st.set_uv(uv_value_left_start)
		st.add_vertex(trail_point_left_start)
		st.set_uv(uv_value_right_end)
		st.add_vertex(trail_point_right_end)

	st.generate_normals()
	_trail_mesh_instance.mesh = st.commit()
