extends Node

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if OS.has_feature("HTML5"):
		if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else: 
		if event is InputEventKey \
		and  event.is_pressed() \
		and (
			event.keycode == KEY_F11 \
			or (
				event.keycode == KEY_ENTER and \
				event.is_alt_pressed()
			)
		):
			get_tree().root.mode = Window.MODE_WINDOWED \
				if get_tree().root.mode == Window.MODE_FULLSCREEN \
				else Window.MODE_FULLSCREEN
