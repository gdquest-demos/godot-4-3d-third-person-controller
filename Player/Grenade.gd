extends RigidBody3D

const EXPLOSION_SCENE := preload("res://Player/ExplosionVisuals/explosion_scene.tscn")
const EXPLOSION_TIMER := 0.2

@onready var _explosion_area: Area3D = $ExplosionArea
@onready var _explosion_sound: AudioStreamPlayer3D = $ExplosionSound
@onready var _player: Node3D = null
@onready var _curve: Curve3D = null
@onready var _curve_offset: Vector3
@onready var _collided: bool = false


func _physics_process(_delta) -> void:
	# The throw velocity is not accurate, so we need to fix it using the closest point in the 3D 
	# curve given to the grenade. This method preserves the physical aspect of the trajectory while
	# respecting the curve the player expects to see
	if not _collided:
		var closest_curve_point := _curve.get_closest_point(global_position - _curve_offset)
		var fixed_position := _curve_offset + closest_curve_point
		global_position = lerp(global_position, fixed_position, 0.7)
		
		# If it's close to last point in the curve, we just explode the grenade
		if closest_curve_point.distance_to(_curve.get_baked_points()[-1]) < 0.1:
			_collided = true
			_explode()


func throw(throw_velocity: Vector3, player: Node3D, curve: Curve3D) -> void:
	_curve_offset = global_position
	linear_velocity = throw_velocity
	_player = player
	_curve = curve.duplicate()
	
	await get_tree().physics_frame
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body != _player and not _collided:
		_collided = true
		_explode()


func _explode() -> void:
	body_entered.disconnect(_explode)
	await get_tree().create_timer(EXPLOSION_TIMER).timeout
	
	_explosion_sound.pitch_scale = randfn(2.0, 0.1)
	_explosion_sound.play()
	
	var bodies := _explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("damageables") and not body.is_in_group("player"):
			# add some variance to the impact point
			var impact_point := (global_position - body.global_position).normalized()
			impact_point = (impact_point + Vector3.DOWN).normalized() * 0.5
			var force := -impact_point * 10.0
			body.damage(impact_point, force)
	
	var explosion: Node3D = EXPLOSION_SCENE.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	hide()
	await _explosion_sound.finished
	queue_free()
