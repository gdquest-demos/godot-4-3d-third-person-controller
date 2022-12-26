@tool
extends Node3D

const POINTS_IN_CURVE3D := 8

@export var gravity := 10.0 : 
	set(value):
		gravity = value
		recalculate_and_redraw()
@export var velocity_start := Vector3.FORWARD * 5.0 + Vector3.UP * 12.5

@onready var path_3d: Path3D = $Path3D

@onready var start: MeshInstance3D = $Start
@onready var target: MeshInstance3D = $Target

var count := 0


func _physics_process(delta: float) -> void:
	count = wrapi(count + 1, 0, 2)
	if count == 0:
		recalculate_and_redraw()

func recalculate_and_redraw() -> void:
	velocity_start = calculate_start_velocity()
	redraw()


func calculate_start_velocity() -> Vector3:
	var peak_height: float = max(target.global_position.y + 0.25, start.global_position.y + 0.25)
	
	var motion_up := peak_height - start.global_position.y
	var time_going_up := sqrt(2.0 * motion_up / gravity)
	
	var motion_down := target.global_position.y - peak_height
	var time_going_down := sqrt(-2.0 * motion_down / gravity)
	
	var time := time_going_up + time_going_down

	var target_position_xz_plane := Vector3(target.global_position.x, 0.0, target.global_position.z)
	var start_position_xz_plane := Vector3(start.global_position.x, 0.0, start.global_position.z)

	var forward_velocity := (target_position_xz_plane - start_position_xz_plane) / time
	var velocity_up := sqrt(2.0 * gravity * motion_up)
	return Vector3.UP * velocity_up + forward_velocity


func redraw() -> void:
	path_3d.curve.clear_points()
	for i in range(POINTS_IN_CURVE3D + 1):
		var time_current := 1.6 * float(i) / float(POINTS_IN_CURVE3D)
		var point := velocity_start * time_current + Vector3.DOWN * gravity * 0.5 * time_current * time_current
		path_3d.curve.add_point(point)
