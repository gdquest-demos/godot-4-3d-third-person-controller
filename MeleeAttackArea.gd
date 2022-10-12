extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3d



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(Callable(self, "_on_body_entered"))


func activate():
	collision_shape.set_deferred("disabled", false)


func deactivate():
	collision_shape.set_deferred("disabled", true)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("damageables"):
		body.damage()
