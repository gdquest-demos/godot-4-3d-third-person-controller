extends Node3D

@export var scale_decay: Curve
@export var distance_limit: float = 5.0

var velocity: Vector3 = Vector3.ZERO
var shooter: Node = null

@onready var _area: Area3D = $Area3d
@onready var _bullet_visuals: Node3D = $Bullet
@onready var _projectile_sound: AudioStreamPlayer3D = $ProjectileSound

@onready var _time_alive := 0.0
@onready var _alive_limit := 0.0


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	look_at(global_position + velocity)
	_alive_limit = distance_limit / velocity.length()
	_projectile_sound.pitch_scale = randfn(1.0, 0.1)
	_projectile_sound.play()


func _process(delta: float) -> void:
	global_position += velocity * delta
	_time_alive += delta
	
	_bullet_visuals.scale = Vector3.ONE * scale_decay.sample(_time_alive/_alive_limit)
	
	if _time_alive > _alive_limit:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body == shooter:
		return
	if body.is_in_group("damageables"):
		var impact_point := global_position - body.global_position
		body.damage(impact_point, velocity)
	queue_free()
