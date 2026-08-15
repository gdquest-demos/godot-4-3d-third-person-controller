extends TextureButton

@export var link := ""


func _ready() -> void:
	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	OS.shell_open(link)
