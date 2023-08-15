extends Node3D

@export var y_amplitude := 0.04


func _process(delta):
	var t := Time.get_ticks_msec() / 1000.0;
	rotation.y += 1.5 * delta
	position.y = sin(t) * y_amplitude;
