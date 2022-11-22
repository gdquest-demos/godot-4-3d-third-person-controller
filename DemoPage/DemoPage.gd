extends Node

@onready var demo_page_root: Control = $CanvasLayer/DemoPageRoot


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		if get_tree().paused:
			resume_demo()
		else:
			pause_demo()


func _ready() -> void:
	get_tree().paused = true


func pause_demo() -> void:
	get_tree().paused = true
	demo_page_root.show()
	var tween := create_tween()
	tween.tween_property(demo_page_root, "modulate", Color.WHITE, 0.3)


func resume_demo() -> void:
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(demo_page_root, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(demo_page_root.hide)
