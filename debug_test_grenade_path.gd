@tool
extends Node3D

const POINTS_IN_CURVE3D := 40

@export var gravity := 10.0 : 
	set(value):
		gravity = value
		recalculate_and_redraw()
@export var velocity_start := Vector3.FORWARD * 5.0 + Vector3.UP * 12.5

@onready var path_3d: Path3D = $Path3D

@onready var start: MeshInstance3D = $Start
@onready var peak: MeshInstance3D = $Peak
@onready var target: MeshInstance3D = $Target


func recalculate_and_redraw() -> void:
	velocity_start = calculate_start_velocity()
	redraw()


func calculate_start_velocity() -> Vector3:
	var motion_up := peak.global_position.y - start.global_position.y
	var time_going_up := sqrt(2.0 * motion_up / gravity)
	
	var motion_down := target.global_position.y - peak.global_position.y
	var time_going_down := sqrt(-2.0 * motion_down / gravity)
	
	var time := time_going_up + time_going_down
	var forward_speed: float = abs(target.global_position.z - start.global_position.z) / time
	var velocity_up := sqrt(2.0 * gravity * motion_up)
	return Vector3(0.0, velocity_up, -forward_speed)


func redraw() -> void:
	path_3d.curve.clear_points()
	for i in range(POINTS_IN_CURVE3D + 1):
		var time_current := 1.6 * float(i) / float(POINTS_IN_CURVE3D)
		var point := velocity_start * time_current + Vector3.DOWN * gravity * 0.5 * time_current * time_current
		path_3d.curve.add_point(point)
