class_name GrenadeLauncher
extends Node3D

const GRENADE_SCENE := preload("res://Player/Grenade.tscn")
const TRAIL_SIZE := 0.25

@export var min_throw_distance := 7.0
@export var max_throw_distance := 16.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _throw_velocity := Vector3.ZERO

@onready var _snap_mesh: Node3D = %SnapMesh
@onready var _raycast: ShapeCast3D = %ShapeCast3D
@onready var _launch_point: Marker3D = %LaunchPoint
@onready var _trail_mesh_instance: MeshInstance3D = %TrailMeshInstance
@onready var _trail_points: Array[Vector3] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	if visible:
		update_aim()


func throw_grenade() -> bool:
	if not visible:
		return false
	
	var grenade := GRENADE_SCENE.instantiate()
	get_parent().add_child(grenade)
	# Add small vertical correction to avoid spawning the grenade under the floor
	grenade.global_position = _launch_point.global_position
	grenade.throw(_throw_velocity)
	return true


func update_aim() -> void:
	var camera := get_viewport().get_camera_3d()
	var up_ratio: float = clamp(max(camera.rotation.x + 0.5, -0.4) * 2, 0.0, 1.0)

	var camera_direction := camera.quaternion * Vector3.FORWARD
	# If the player's not aiming, the camera's far behind the character, so we increase the ray's
	# length based on how far behind the camera is compared to the character.
	var base_throw_distance: float = lerp(min_throw_distance, max_throw_distance, up_ratio)
	var camera_forward_distance := camera.global_position.project(camera_direction).distance_to(_launch_point.global_position.project(camera_direction))
	var throw_distance := base_throw_distance + camera_forward_distance
	var global_camera_look_position := camera.global_position + camera_direction * throw_distance
	_raycast.target_position = global_camera_look_position - _raycast.global_position

	# Snap grenade land position to an enemy the player's aiming at, if applicable
	var to_target := _raycast.target_position
	var collider := _raycast.get_collider(0)
	var has_target: bool = collider and collider.is_in_group("targeteables")
	_snap_mesh.visible = has_target
	if has_target:
		to_target = collider.global_position - _launch_point.global_position
		_snap_mesh.global_position = _launch_point.global_position + to_target
		_snap_mesh.look_at(_launch_point.global_position)

	# Calculate the initial velocity the grenade needs based on where we want it to land and how
	# high the curve should go.
	var peak_height: float = max(to_target.y + 0.25, _launch_point.position.y + 0.25)
	
	var motion_up := peak_height
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
#	_grenade_path.curve.clear_points()
	_trail_points.clear()
	const TIME_STEP := 0.05
	var time_current := 0.0
	var end_time := time_to_land + 0.5
	while time_current < end_time:
		var point := _throw_velocity * time_current + Vector3.DOWN * gravity * 0.5 * time_current * time_current
		_trail_points.append(point)
		time_current += TIME_STEP
	_generate_mesh()


func _generate_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# We'll use trail_direction to get the left and right points difference from
	# the _trail_points 
	var trail_direction = (_trail_points[-1] - _trail_points[0]).normalized()
	trail_direction.y = 0.0
	var cross_dir := Vector3.UP.cross(trail_direction)
	var mesh_left_diff = cross_dir * TRAIL_SIZE/2.0
	var mesh_right_diff = -cross_dir * TRAIL_SIZE/2.0

	for i in range(_trail_points.size()-1):
		# We'll create 2 triangles on each iteration, representing the quad of
		# one section of the path (between two points of _trail_points)
		
		# _trail_points represents the points in the "center" of the path, so
		# we'll derive the two points in the left and the two points in the right
		var trail_point_left_1 = _trail_points[i] + mesh_left_diff
		var trail_point_right_1 = _trail_points[i] + mesh_right_diff
		var trail_point_left_2 = _trail_points[i+1] + mesh_left_diff
		var trail_point_right_2 = _trail_points[i+1] + mesh_right_diff
		
		# UV position goes from 0 to 1, so we normalize the current iteration
		# to get the progress in the UV texture
		var uv_progress_1 = (float(i)/(_trail_points.size()-1.0))
		var uv_progress_2 = (float(i+1.0)/(_trail_points.size()-1.0))
		
		# Left side on the UV texture is at the top of the texture
		# (Vector2(0,1), or Vector2.DOWN). Right side on the UV texture is at 
		# the bottom.
		var uv_value_left_1 = Vector2.DOWN + (Vector2.RIGHT * uv_progress_1)
		var uv_value_left_2 = Vector2.DOWN + (Vector2.RIGHT * uv_progress_2)
		var uv_value_right_1 = (Vector2.RIGHT * uv_progress_1)
		var uv_value_right_2 = (Vector2.RIGHT * uv_progress_2)
		
		# Both triangles need to be set in the same orientation (Godot
		# uses clockwise orientation to determine the face normal)

		# Set first triangle
		st.set_uv(uv_value_left_1)
		st.add_vertex(trail_point_left_1)
		st.set_uv(uv_value_left_2)
		st.add_vertex(trail_point_left_2)
		st.set_uv(uv_value_right_1)
		st.add_vertex(trail_point_right_1)
		
		# Set second triangle
		st.set_uv(uv_value_right_1)
		st.add_vertex(trail_point_right_1)
		st.set_uv(uv_value_left_2)
		st.add_vertex(trail_point_left_2)
		st.set_uv(uv_value_right_2)
		st.add_vertex(trail_point_right_2)
	
	st.generate_normals()
	_trail_mesh_instance.mesh = st.commit()
