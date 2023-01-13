extends Control

@onready var benchmark: QualitySettingsBenchmark = $Benchmark


func _ready() -> void:
	QualitySettings.setup()
	
	if QualitySettings.current_setting_path.is_empty():
		
		# On a GTX960M, the following seconds-per-frame were obtained:
		#   QUALITY SETTINGS  |   BENCHMARK   |   GAME   |
		#        LOW          |     0.011     |   0.013  |
		#       MEDIUM        |     0.12      |   0.05   |
		#        HIGH         |     0.19      |   0.13   |
		
		# Low settings are not representative of the worst case-scenario, so
		# we'll use a benchmark difficulty of 0.5 (benchmark FPS expectation is half of the real
		# game FPS) to get the optimal quality setting
		
		const TARGET_SPF = 0.016
		const BENCHMARK_DIFFICULTY = 0.5
		
		await benchmark.benchmark()
		var optimal_setting: QualitySettingsResource = benchmark.get_optimal_result(TARGET_SPF, BENCHMARK_DIFFICULTY)
		QualitySettings.current_setting_path = optimal_setting.resource_path
		QualitySettings.save_on_user()
	
	get_tree().change_scene_to_file("res://Main.tscn")
