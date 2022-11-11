extends Node3D

var rotation_axis := Vector3(1.0, 0.0, 0.0).normalized()

func _ready():
	$AnimationPlayer.play("wave")

func _process(delta):
	rotate_object_local(rotation_axis, 10.0 * delta)
	
