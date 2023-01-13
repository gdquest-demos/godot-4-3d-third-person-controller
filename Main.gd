extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var mspf_label: Label = %MSPFLabel
@onready var _frame := 0


func _ready() -> void:
	if not QualitySettings.current_setting_path.is_empty():
		var quality_settings: QualitySettingsResource = load(QualitySettings.current_setting_path)
		quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _physics_process(delta: float) -> void:
	_frame += 1
	if _frame > 10:
		_frame = 0
		mspf_label.text = "%0.3f msfp" % (1.0 / Engine.get_frames_per_second())
