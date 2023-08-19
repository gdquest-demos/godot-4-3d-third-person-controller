extends Node3D

@onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/StateMachine/playback"]

func _ready():
	$AnimationTree.active = true
	play_idle()

func play_idle():
	state_machine.travel("idle")

func play_spit_attack():
	state_machine.travel("spit_attack")

func play_poweroff():
	state_machine.travel("power_off")

func _exit_tree(): # When someone calls queue_free() here
	$bee_bot/Armature/Skeleton3D/bee_bot2.set("surface_material_override/1", null)
	$bee_bot/Armature/Skeleton3D/bee_bot2.set("surface_material_override/2", null)
	$bee_bot/Armature/Skeleton3D/bee_bot2.set("surface_material_override/3", null)
