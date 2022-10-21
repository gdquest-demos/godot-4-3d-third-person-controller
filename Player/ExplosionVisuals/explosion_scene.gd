extends Node3D

func _ready():
	$AnimationPlayer.play("explosion")
	await $AnimationPlayer.animation_finished
	queue_free()
	
