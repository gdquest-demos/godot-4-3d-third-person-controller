extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var mspf_label: Label = %MSPFLabel
@onready var demo_page: DemoPage = %DemoPage
@onready var _frame := 0


func _ready() -> void:
	QualitySettings.current_quality_settings.apply_settings(get_tree().root, world_environment.environment)
	demo_page.setup_quality_settings(QualitySettings.current_setting_idx, QualitySettings.quality_settings_resources.size())
	demo_page.quality_settings_applied.connect(_on_quality_settings_applied)


func _on_quality_settings_applied(quality_settings_idx) -> void:
	QualitySettings.current_setting_idx = quality_settings_idx
	QualitySettings.save_on_user()
	QualitySettings.current_quality_settings.apply_settings(get_tree().root, world_environment.environment)


func _physics_process(delta: float) -> void:
	_frame += 1
	if _frame > 10:
		_frame = 0
		mspf_label.text = "%0.3f msfp" % (1.0 / Engine.get_frames_per_second())
