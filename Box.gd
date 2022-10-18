extends RigidBody3D

const COLLECTIBLE_SCENE := preload("res://Collectible.tscn")
const COLLECTIBLES_COUNT := 5


func damage(impact_point: Vector3, force: Vector3):
	for i in range(COLLECTIBLES_COUNT):
		var collectible := COLLECTIBLE_SCENE.instantiate()
		get_parent().add_child(collectible)
		collectible.global_position = global_position
		collectible.spawn()
	queue_free()
