class_name QualitySettingsCache
extends Node

const FILE_PATH := "user://quality_settings"

@export var quality_settings_resources : Array[QualitySettingsResource] = []

var current_setting_idx: int = -1

var current_quality_settings: QualitySettingsResource :
	get:
		return quality_settings_resources[current_setting_idx]


func setup() -> void:
	save_on_user()
	if not FileAccess.file_exists(FILE_PATH):
		save_on_user()
	load_from_user()


func save_on_user() -> void:
	var serialized := {}
	serialized["current_setting_idx"] = current_setting_idx
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(serialized)


func load_from_user() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var serialized: Dictionary = file.get_var()
	current_setting_idx = serialized["current_setting_idx"]
