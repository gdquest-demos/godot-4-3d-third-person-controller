extends Node3D


func _input(event):
	# Make sure mouse is captured in WebGL context.
	# If desktop is affected, guard with an additional
	# `OS.has_feature("html5")`
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
