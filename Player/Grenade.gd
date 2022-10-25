extends RigidBody3D

const EXPLOSION_SCENE := preload("res://Player/ExplosionVisuals/explosion_scene.tscn")
# Godot Physics makes the trajectory slightly weaker, so we
# multiply by TRAJECTORY_CORRECTION to fix that
const TRAJECTORY_CORRECTION := 1.05
const EXPLOSION_TIMER := 0.2

@onready var _collision_area: CollisionShape3D = $CollisionShape3d
@onready var _explosion_area: Area3D = $ExplosionArea
@onready var _player: Node3D = null


func throw(throw_velocity: Vector3, player: Node3D) -> void:
	linear_velocity = throw_velocity * TRAJECTORY_CORRECTION
	_player = player
	
	await get_tree().physics_frame
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body != _player:
		_explode()


func _explode() -> void:
	body_entered.disconnect(_explode)
	await get_tree().create_timer(EXPLOSION_TIMER).timeout
	
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
	explosion.global_position = global_position
	queue_free()
