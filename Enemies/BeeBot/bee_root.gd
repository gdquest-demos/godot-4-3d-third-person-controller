extends Node3D

@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/StateMachine/playback"]

func _ready():
	play_idle()

func play_idle():
	state_machine.travel("play_idle")

func play_spit_attack():
	state_machine.travel("spit_attack")

func play_poweroff():
	state_machine.travel("power_off")
