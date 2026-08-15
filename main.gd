extends Node3D


func _ready() -> void:
	await RenderingServer.frame_post_draw
	%FixStutters.queue_free()
