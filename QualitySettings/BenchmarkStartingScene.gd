extends Control

@onready var benchmark: QualitySettingsBenchmark = $Benchmark


func _ready() -> void:
	QualitySettings.setup()
	
	if QualitySettings.current_setting_path.is_empty():
		
		benchmark.benchmark()
		var optimal_setting: QualitySettingsResource = benchmark.get_optimal_result(0.016 * 1.25)
		QualitySettings.current_setting_path = optimal_setting.resource_path
		QualitySettings.save_on_user()
	
	get_tree().change_scene_to_file("res://Main.tscn")
