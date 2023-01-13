extends Control

@onready var benchmark: QualitySettingsBenchmark = $Benchmark


func _ready() -> void:
#	return
	await RenderingServer.frame_post_draw

	QualitySettings.setup()
	
	if true: #QualitySettings.current_setting_path.is_empty():
		
		const TARGET_SPF = 0.016 * 1.25
		
		benchmark.benchmark()
		var optimal_setting: QualitySettingsResource = benchmark.get_optimal_result(TARGET_SPF)
		QualitySettings.current_setting_path = optimal_setting.resource_path
		QualitySettings.save_on_user()
	
	get_tree().change_scene_to_file("res://Main.tscn")
