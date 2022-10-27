extends Node3D


func _ready():
	idle_loop()


func idle_loop():
	# Play animation
	$AnimationTree["parameters/OneShot/active"] = true
	var t = get_tree().create_timer(randf_range(2.0, 8.0))
	await t.timeout
	idle_loop()
