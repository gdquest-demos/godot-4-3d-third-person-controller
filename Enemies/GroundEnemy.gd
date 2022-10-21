extends RigidBody3D

const COIN_SCENE := preload("res://Coin/Coin.tscn")

@export var collectibles_count := 5
@export var stopping_distance := 0.0

@onready var _reaction_animation_player: AnimationPlayer = $ReactionLabel/AnimationPlayer
@onready var _detection_area: Area3D = $PlayerDetectionArea
@onready var _mesh_instance: MeshInstance3D = $MeshRoot/MeshInstance3D
@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent3D

@onready var _target: Node3D = null
@onready var _alive: bool = true


func _ready() -> void:
	_detection_area.body_entered.connect(_on_body_entered)
	_detection_area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if _target != null and _alive:
		_navigation_agent.set_target_location(_target.global_position)
		
		var next_location := _navigation_agent.get_next_location()
		
		if not _navigation_agent.is_target_reached():
			var direction := (next_location - global_position)
			direction.y = 0
			direction = direction.normalized()
			
			var collision := move_and_collide(direction * delta * 3)
			if collision:
				var collider := collision.get_collider()
				if collider is Player:
					var impact_point: Vector3 = global_position - collider.global_position
					var force := -impact_point
					# Throws player up a little bit
					force.y = 0.5
					force *= 10.0
					collider.damage(impact_point, force)


func damage(impact_point: Vector3, force: Vector3) -> void:
	lock_rotation = false
	force = force.limit_length(3.0)
	apply_impulse(force, impact_point)

	if not _alive:
		return
	
	_alive = false
	
	for i in range(collectibles_count):
		var collectible := COIN_SCENE.instantiate()
		get_parent().add_child(collectible)
		collectible.global_position = global_position
		collectible.spawn()
	_detection_area.body_entered.disconnect(_on_body_entered)
	_detection_area.body_exited.disconnect(_on_body_exited)
	_target = null
	
	gravity_scale = 1.0


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_target = body
		_reaction_animation_player.play("found_player")


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_target = null
		_reaction_animation_player.play("lost_player")
