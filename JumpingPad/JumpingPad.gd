extends Area3D

@export var impulse_strenght := 10.0
@onready var mushroom : Node3D = %mushroom

func _ready() -> void:
	body_entered.connect(func(body):
		if body is Player:
			body.velocity = (Vector3.UP * body.jump_initial_impulse) + (transform.basis * Vector3.UP * impulse_strenght)
			
			var tween := create_tween()
			mushroom.scale.y = 0.4
			tween.tween_property(mushroom, "scale:y", 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	)
