extends RigidBody3D

const COIN_SCENE := preload("res://Coin/Coin.tscn")
const COLLECTIBLES_COUNT := 5
const DESTROYED_BOX_SCENE := preload("res://Box/DestroyedBox.tscn")


func damage(impact_point: Vector3, force: Vector3):
	for i in range(COLLECTIBLES_COUNT):
		var collectible := COIN_SCENE.instantiate()
		get_parent().add_child(collectible)
		collectible.global_position = global_position
		collectible.spawn()
	
	var destroyed_box := DESTROYED_BOX_SCENE.instantiate()
	get_parent().add_child(destroyed_box)
	destroyed_box.global_position = global_position
	
	queue_free()
