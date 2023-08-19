extends Node3D

const FLYING_PIECES := 3
const THROW_STRENGTH := 500

@onready var _pieces_idx := [0, 1, 2, 3, 4, 5]


func _ready() -> void:
	_pieces_idx.shuffle()

	for i in range(FLYING_PIECES):
		var piece_idx: int = _pieces_idx[i]
		var piece: RigidBody3D = get_child(piece_idx)
		piece.show()
		piece.freeze = false
		piece.sleeping = false
		piece.set_collision_mask_value(1, true)
		
		var rand_vector := (Vector3.ONE * 0.5) - Vector3(randf(), randf(), randf())
		
		piece.apply_force(rand_vector * THROW_STRENGTH, rand_vector)
