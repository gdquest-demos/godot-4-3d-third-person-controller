extends Node3D

@export var throw_curve: Curve
@export var throw_additional_height := 2.0
@export var throw_speed := 20.0

@onready var _collision_area: Area3D = $CollisionDetectionArea
@onready var _explosion_area: Area3D = $ExplosionArea

@onready var _initial_position := Vector3.ZERO
@onready var _target_position := Vector3.ZERO
@onready var _max_height := 0.0
@onready var _player: Node3D = null


func _ready() -> void:
	_collision_area.body_entered.connect(_on_collision_body_entered)


func throw(target_position: Vector3, player: Node3D) -> void:
	_max_height = max(target_position.y, global_position.y) + throw_additional_height
	_initial_position = global_position
	_target_position = target_position
	_player = player
	
	var xz_direction := _target_position - _initial_position
	xz_direction.y = 0.0
	var xz_distance = xz_direction.length()
	var throw_duration: float = max(xz_distance/throw_speed, 1.0)
	
	var tween := create_tween()
	tween.tween_method(_interpolate_position, 0.0, 1.0, throw_duration)
	tween.tween_callback(_explode)


func _on_collision_body_entered(body) -> void:
	if body != _player:
		_explode()


func _explode() -> void:
	var bodies := _explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("damageables"):
			body.damage()
	
	queue_free()


func _interpolate_position(offset: float) -> void:
	var additional_height := throw_curve.sample(offset) * throw_additional_height
	global_position = lerp(_initial_position, _target_position, offset)
	global_position.y += additional_height
