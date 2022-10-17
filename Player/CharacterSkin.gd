class_name CharacterSkin
extends Node3D

var animation_tree
var state_machine
var moving_blend_path = "parameters/StateMachine/move/blend_position"

# False : set animation to "idle"
# True : set animation to "move"
var moving : bool = false : set = set_moving

# Blend value between the walk and run cycle
# 0.0 walk - 1.0 run
var move_speed : float = 0.0 : set = set_moving_speed

func _ready():
	animation_tree = $AnimationTree
	state_machine = animation_tree.get("parameters/StateMachine/playback")
	
func set_moving(value : bool):
	moving = value
	if moving:
		state_machine.travel("move")
	else:
		state_machine.travel("idle")
	
func set_moving_speed(value : float):
	move_speed = clamp(value, 0.0, 1.0)
	animation_tree.set(moving_blend_path, move_speed)
	
func jump():
	state_machine.travel("jump")

func fall():
	state_machine.travel("fall")
