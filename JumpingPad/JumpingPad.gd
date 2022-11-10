extends Area3D

@export var impulse_strenght := 8.0
@onready var _player: CharacterBody3D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if _player:
		var player_is_just_jumping := Input.is_action_just_pressed("jump")
		if player_is_just_jumping:
			_player.velocity += transform.basis * Vector3.UP * impulse_strenght


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_player = body


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_player = null
