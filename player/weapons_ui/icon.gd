extends TextureRect

var disabled_alpha := 0.2

func _ready():
	modulate.a = disabled_alpha

func set_state(state: bool):
	var from_to := [Color(1, 1, 1, disabled_alpha), Color.WHITE]
	if state : from_to.reverse()
	var tween := create_tween()
	tween.tween_property(self, "modulate", from_to[0], 0.2).from(from_to[1])
