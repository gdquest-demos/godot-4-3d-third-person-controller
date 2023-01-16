extends RigidBody3D

const COIN_SCENE := preload("res://Player/Coin/Coin.tscn")
const BULLET_SCENE := preload("res://Player/Bullet.tscn")
const PUFF_SCENE := preload("smoke_puff/smoke_puff.tscn")

@export var shoot_timer := 1.5
@export var bullet_speed := 6.0
@export var coins_count := 5

@onready var _reaction_animation_player: AnimationPlayer = $ReactionLabel/AnimationPlayer
@onready var _flying_animation_player: AnimationPlayer = $MeshRoot/AnimationPlayer
@onready var _detection_area: Area3D = $PlayerDetectionArea
@onready var _death_mesh_collider: CollisionShape3D = $DeathMeshCollider
@onready var _bee_root: Node3D = $MeshRoot/bee_root
@onready var _defeat_sound: AudioStreamPlayer3D = $DefeatSound

@onready var _shoot_count := 0.0
@onready var _target: Node3D = null
@onready var _alive: bool = true


func _ready() -> void:
	_detection_area.body_entered.connect(_on_body_entered)
	_detection_area.body_exited.connect(_on_body_exited)
	_bee_root.play_idle()


func _physics_process(delta: float) -> void:
	if _target != null and _alive:
		var target_transform := transform.looking_at(_target.global_position)
		transform = transform.interpolate_with(target_transform, 0.1)
		
		_shoot_count += delta
		if _shoot_count > shoot_timer:
			_bee_root.play_spit_attack()
			_shoot_count -= shoot_timer
			
			var bullet := BULLET_SCENE.instantiate()
			bullet.shooter = self
			var origin := global_position
			var target := _target.global_position + Vector3.UP
			var aim_direction := (target - global_position).normalized()
			bullet.velocity = aim_direction * bullet_speed
			bullet.distance_limit = 14.0
			get_parent().add_child(bullet)
			bullet.global_position = origin


func damage(impact_point: Vector3, force: Vector3) -> void:
	force = force.limit_length(3.0)
	apply_impulse(force, impact_point)

	if not _alive:
		return
	
	_defeat_sound.play()
	_alive = false
	
	_flying_animation_player.stop()
	_flying_animation_player.seek(0.0, true)
	_detection_area.body_entered.disconnect(_on_body_entered)
	_detection_area.body_exited.disconnect(_on_body_exited)
	_target = null
	_death_mesh_collider.set_deferred("disabled", false)
	
	gravity_scale = 1.0
	_bee_root.play_poweroff()
	
	await get_tree().create_timer(2).timeout
	
	var puff := PUFF_SCENE.instantiate()
	get_parent().add_child(puff)
	puff.global_position = global_position
	await puff.full
	for i in range(coins_count):
		var coin := COIN_SCENE.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
		coin.spawn()
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_shoot_count = 0.0
		_target = body
		_reaction_animation_player.play("found_player")


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_target = null
		_reaction_animation_player.play("lost_player")
