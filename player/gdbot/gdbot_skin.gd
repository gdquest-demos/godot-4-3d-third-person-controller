class_name CharacterSkin
extends Node3D

## Emitted when Gobot's feet hit the ground will running.
@warning_ignore("unused_signal")
signal stepped

## Represents the blending between the walking and running animations.
## It can be set to different values (e.g. 0.0 to 1.0) to adjust the balance between
## the two animations, resulting in the model appearing to walk or run depending on the value.
@export_range(0.0, 1.0, 0.01) var walk_run_blending = 0.0:
	set = set_walk_run_blending

@onready var _animation_tree: AnimationTree = %AnimationTree
@onready var _main_state_machine: AnimationNodeStateMachinePlayback = _animation_tree.get("parameters/StateMachine/playback")
@onready var _walk_run_blend_amount := "parameters/StateMachine/Move/WalkRunBlending/blend_amount"
@onready var _step_time_scale := "parameters/StateMachine/Move/StepTimeScale/scale"
@onready var _walk_run_ratio := _animation_tree.get_animation("walk").length / _animation_tree.get_animation("run").length
@onready var _attack_one_shot := "parameters/AttackOneShot/request"
@onready var _face: Node2D = %GDbotFace


func _ready() -> void:
	walk_run_blending = walk_run_blending


func set_walk_run_blending(value: float) -> void:
	walk_run_blending = clampf(value, 0.0, 1.0)
	if not is_node_ready():
		return
	_animation_tree.set(_walk_run_blend_amount, walk_run_blending)
	_animation_tree.set(_step_time_scale, lerpf(1.0, _walk_run_ratio, walk_run_blending))


## Sets the model to a neutral, action-free state.
func idle() -> void:
	_main_state_machine.travel("Idle")


## Sets the model to a walking or running animation or forward movement.
func move() -> void:
	_main_state_machine.travel("Move")


## Sets the model to an upward-leaping animation, simulating a jump.
func jump() -> void:
	_main_state_machine.travel("Jump")


## Sets the model to a downward animation, imitating a fall.
func fall() -> void:
	_main_state_machine.travel("Fall")


func attack() -> void:
	_animation_tree.set(_attack_one_shot, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


## Changes the model's facial expression based on the provided input string values.
## Possible expressions include "default" (for default blinking),
## "happy" (for a joyful expression), "dizzy" (for spiraling eyes),
## and "sleepy" (for a drowsy countenance).
## [br][b]Note:[/b] To add new expressions, you can edit gdbot_face.tscn, which is a 2D scene
## utilized by a viewport node to display on Gdbot's face.
func set_face(face_name: String) -> void:
	_face._set_face(face_name)
