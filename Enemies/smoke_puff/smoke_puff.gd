extends Node3D

# Emit when smoke density is at maxium
signal full

@onready var smoke_sounds := $SmokeSounds.get_children()


func _ready():
	smoke_sounds.pick_random().play()
	
	$AnimationPlayer.play("poof")
	await $AnimationPlayer.animation_finished
	queue_free()


func smoke_at_full_density():
	full.emit()
