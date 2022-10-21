extends Path3D

const EXPLOSION_SCENE := preload("res://Player/ExplosionVisuals/explosion_scene.tscn")

@export var throw_speed := 20.0

@onready var _path_follow: PathFollow3D = $PathFollow3D
@onready var _collision_area: Area3D = $PathFollow3D/CollisionDetectionArea
@onready var _explosion_area: Area3D = $PathFollow3D/ExplosionArea
@onready var _player: Node3D = null

func _physics_process(delta: float) -> void:
	var frame_distance := throw_speed * delta
	_path_follow.progress += frame_distance
	
	if _path_follow.progress_ratio >= 1.0:
		_explode()


func throw(grenade_curve: Curve3D, player: Node3D) -> void:
	curve = grenade_curve
	_player = player
	
	# wait a frame to update body position
	await get_tree().physics_frame
	_collision_area.body_entered.connect(_on_collision_body_entered)


func _on_collision_body_entered(body) -> void:
	if body != _player:
		_explode()


func _explode() -> void:
	var bodies := _explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("damageables"):
			# add some variance to the impact point
			var impact_point := (global_position - body.global_position).normalized()
			impact_point = (impact_point + Vector3.DOWN).normalized() * 0.5
			var force := -impact_point * 10.0
			body.damage(impact_point, force)
	
	var explosion: Node3D = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = _path_follow.global_position
	queue_free()
