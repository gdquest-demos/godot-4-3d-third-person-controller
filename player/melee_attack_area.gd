extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func is_active() -> bool:
	return monitoring


func activate() -> void:
	monitoring = true


func deactivate() -> void:
	monitoring = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("damageables"):
		var impact_point := global_position - body.global_position
		var force := -impact_point
		body.damage(impact_point, force)
