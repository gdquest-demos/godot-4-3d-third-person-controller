extends RigidBody3D

const COIN_SCENE := preload("res://Player/Coin/Coin.tscn")
const COINS_COUNT := 5
const DESTROYED_BOX_SCENE := preload("res://Box/DestroyedBox.tscn")


func damage(_impact_point: Vector3, _force: Vector3):
	for i in range(COINS_COUNT):
		var coin := COIN_SCENE.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
		coin.spawn()
	
	var destroyed_box := DESTROYED_BOX_SCENE.instantiate()
	get_parent().add_child(destroyed_box)
	destroyed_box.global_position = global_position
	
	queue_free()
