@tool
extends Node3D


func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0;
	rotation.y += 1.5 * delta
	position.y = sin(t) * 0.04;
