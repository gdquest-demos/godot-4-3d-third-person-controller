class_name Coin
extends RigidBody3D

const MIN_LAUNCH_RANGE := 2.0
const MAX_LAUNCH_RANGE := 4.0
const MIN_LAUNCH_HEIGHT := 1.0
const MAX_LAUNCH_HEIGHT := 3.0

const SPAWN_TWEEN_DURATION := 1.0
const FOLLOW_TWEEN_DURATION := 0.5

@onready var _collect_audio: AudioStreamPlayer3D = $CollectAudio
@onready var _player_detection_area: Area3D = $PlayerDetectionArea
@onready var _initial_tween_position := Vector3.ZERO
@onready var _target: Node3D = null


func spawn(coin_delay: float = 0.5) -> void:
	var rand_height := MIN_LAUNCH_HEIGHT + (randf() * MAX_LAUNCH_HEIGHT)
	var rand_dir := Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI)
	var rand_pos := rand_dir * (MIN_LAUNCH_RANGE + (randf() * MAX_LAUNCH_RANGE))
	rand_pos.y = rand_height
	apply_central_impulse(rand_pos)

	# Delay time for player to be able to collect it
	get_tree().create_timer(coin_delay).timeout.connect(set_collision_layer_value.bind(3, true))
	_player_detection_area.body_entered.connect(_on_body_entered)


func set_target(new_target: PhysicsBody3D) -> void:
	PhysicsServer3D.body_add_collision_exception(get_rid(), new_target.get_rid())

	if _target == null:
		sleeping = true
		freeze = true

		_initial_tween_position = global_position
		_target = new_target
		var tween := create_tween()
		tween.tween_method(_follow, 0.0, 1.0, 0.5)
		tween.tween_callback(_collect)


func _follow(offset: float) -> void:
	global_position = lerp(_initial_tween_position, _target.global_position, offset)


func _on_body_entered(body: PhysicsBody3D) -> void:
	if body is Player:
		set_target(body)


func _collect() -> void:
	_collect_audio.pitch_scale = randfn(1.0, 0.1)
	_collect_audio.play()
	_target.collect_coin()
	hide()
	await _collect_audio.finished
	queue_free()
