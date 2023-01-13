extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	if not QualitySettings.current_setting_path.is_empty():
		print(QualitySettings.current_setting_path)
		var quality_settings: QualitySettingsResource = load(QualitySettings.current_setting_path)
		quality_settings.apply_settings(get_tree().root, world_environment.environment)
