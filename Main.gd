extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
#	return
	var quality_settings: QualitySettingsResource = load(QualitySettings.current_setting_path)
	quality_settings.apply_settings(get_tree().root, world_environment.environment)
