class_name QualitySettingsBenchmark
extends Node

@export_category("Configuration")
@export var viewport: SubViewport
@export var world_environment: WorldEnvironment

@onready var benchmark_results : Array :
	get:
		return _benchmark_results

@onready var _benchmark_results = []


func get_optimal_result(target_seconds_per_frame: float, benchmark_difficulty: float) -> int:
	var target_spf := target_seconds_per_frame / benchmark_difficulty
	
	if _benchmark_results.size() == 0:
		printerr("No results or quality settings set!")
		return -1
	
	var i := 0
	for _i in range(_benchmark_results.size()):
		if _benchmark_results[i][&"failed"] and not _benchmark_results[_i][&"failed"]:
			i = _i
			continue
		
		var i_dta: float = _benchmark_results[i][&"device_timestamp_avg"]
		var _i_dta: float = _benchmark_results[_i][&"device_timestamp_avg"]
		
		if i_dta > target_spf and _i_dta < target_spf:
			i = _i
			continue
		elif i_dta < target_spf and _i_dta > target_spf:
			continue
		
		if abs(i_dta - target_spf) > abs(_i_dta - target_spf):
			i = _i
 
	return i


func benchmark(quality_settings_resources: Array[QualitySettingsResource]) -> void:
	_benchmark_results.clear()
	
	var rendering_device := RenderingServer.get_rendering_device()
	var window_viewport_rid = get_tree().root.get_viewport_rid()
	
	RenderingServer.viewport_set_measure_render_time(viewport.get_viewport_rid(), true)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# TODO: This line helps getting more consistent results, but I'm not sure why.
	await RenderingServer.frame_post_draw
	
	for settings in quality_settings_resources:
		settings.apply_settings(viewport, world_environment.environment)

		var last_device_timestamp := 0
		const RENDER_TIME_THRESHOLD := 0.5
		var FRAME_DELAY := rendering_device.get_frame_delay() + 1
		
		var benchmark_result := {
			&"failed": false,
			&"unix_time_avg": 0.0,
			&"device_timestamp_avg": 0.0,
			&"unix_time_variance": 0.0,
			&"device_timestamp_variance": 0.0,
		}
		
		for i in range(FRAME_DELAY):
			var frame := _capture_render_time(rendering_device, false)
			if frame[&"unix_time_diff"] > RENDER_TIME_THRESHOLD:
				benchmark_result[&"failed"] = true
				break
		
		var frames := []
		
		if not benchmark_result[&"failed"]:
			for i in range(10):
				var frame := _capture_render_time(rendering_device, true)
				if frame[&"unix_time_diff"] > RENDER_TIME_THRESHOLD:
					benchmark_result[&"failed"] = true
					break
				frames.append(frame)

		if not benchmark_result[&"failed"]:
			var unix_time_total := 0.0
			var device_timestamp_total := 0.0
			
			for frame in frames:
				unix_time_total += frame[&"unix_time_diff"]
				device_timestamp_total += frame[&"device_timestamp_diff"]
			
			var unix_time_avg := unix_time_total / 10.0
			var device_timestamp_avg := device_timestamp_total / 10.0
			
			var unix_time_variance := 0.0
			var device_timestamp_variance := 0.0
			
			for frame in frames:
				var variance_diff = (frame[&"unix_time_diff"] - unix_time_avg)
				unix_time_variance += variance_diff * variance_diff
				variance_diff = (frame[&"device_timestamp_diff"] - device_timestamp_avg)
				device_timestamp_variance += variance_diff * variance_diff
			
			unix_time_variance /= 10.0
			device_timestamp_variance /= 10.0
			
			benchmark_result[&"unix_time_avg"] = unix_time_avg
			benchmark_result[&"device_timestamp_avg"] = device_timestamp_avg
			benchmark_result[&"unix_time_variance"] = unix_time_variance
			benchmark_result[&"device_timestamp_variance"] = device_timestamp_variance
		
		_benchmark_results.append(benchmark_result)
	
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED


func _capture_render_time(rendering_device: RenderingDevice, benchmark: bool) -> Dictionary:
	var timestamp := 0.0

	if benchmark:
		timestamp = Time.get_unix_time_from_system()
	
	RenderingServer.force_draw(true)
	
	var unix_time_diff := 0.0
	var device_timestamp_diff = 0.0
	
	if benchmark:
		unix_time_diff = Time.get_unix_time_from_system() - timestamp
		device_timestamp_diff = RenderingServer.viewport_get_measured_render_time_gpu(viewport.get_viewport_rid())/1000.0
	
	return {
		&"device_timestamp_diff": device_timestamp_diff,
		&"unix_time_diff": unix_time_diff,
	}
