class_name Collectible
extends RigidBody3D

const MIN_LAUNCH_RANGE := 2.0
const MAX_LAUNCH_RANGE := 4.0
const MIN_LAUNCH_HEIGHT := 2.0
const MAX_LAUNCH_HEIGHT := 4.0

const SPAWN_TWEEN_DURATION := 1.0
const FOLLOW_TWEEN_DURATION := 0.5

@onready var _initial_tween_position := Vector3.ZERO
@onready var _follow_node: Node3D = null


func spawn() -> void:
	var rand_height = MIN_LAUNCH_HEIGHT + (randf() * MAX_LAUNCH_HEIGHT)
	var rand_dir = Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI)
	var rand_pos = rand_dir * (MIN_LAUNCH_RANGE + (randf() * MAX_LAUNCH_RANGE))
	apply_central_impulse(rand_pos)


func set_follow(follow_node: Node3D) -> void:
	if _follow_node == null:
		sleeping = true
		freeze = true
		
		_initial_tween_position = global_position
		_follow_node = follow_node
		var tween := create_tween()
		tween.tween_method(_follow, 0.0, 1.0, 0.5)
		tween.tween_callback(_collect)


func _follow(offset: float) -> void:
	global_position = lerp(_initial_tween_position, _follow_node.global_position, offset)


func _collect() -> void:
	queue_free()
