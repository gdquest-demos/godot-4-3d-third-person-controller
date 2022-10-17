extends Node3D

@export var throw_curve: Curve
@export var throw_additional_height := 2.0
@export var throw_duration := 1.0

var _initial_position: Vector3
var _target_position: Vector3
var _max_height: float

func throw(target_position: Vector3) -> void:
	_max_height = max(target_position.y, global_position.y) + throw_additional_height
	_initial_position = global_position
	_target_position = target_position
	
	var tween := create_tween()
	tween.tween_method(_interpolate_position, 0.0, 1.0, throw_duration)
	tween.tween_callback(_explode)


func _explode() -> void:
	queue_free()


func _interpolate_position(offset: float) -> void:
	var additional_height := throw_curve.sample(offset) * throw_additional_height
	global_position = lerp(_initial_position, _target_position, offset)
	global_position.y += additional_height
