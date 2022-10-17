extends Node3D

const ALIVE_LIMIT = 5

var velocity: Vector3 = Vector3.ZERO
var shooter: Node = null

@onready var _area: Area3D = $Area3d
@onready var _time_alive := 0.0


func _ready() -> void:
	_area.body_entered.connect(Callable(self, "_on_body_entered"))


func _process(delta: float) -> void:
	global_position += velocity * delta
	_time_alive += delta
	if _time_alive > ALIVE_LIMIT:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	if body.is_in_group("damageables"):
		body.damage()
	queue_free()
