class_name QualitySettingsCache
extends Node

const FILE_PATH := "user://quality_settings"

var current_setting_path: String


func setup() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		save_on_user()
	load_from_user()


func save_on_user() -> void:
	var serialized := {}
	serialized["current_setting_path"] = current_setting_path
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_var(serialized)


func load_from_user() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var serialized: Dictionary = file.get_var()
	current_setting_path = serialized["current_setting_path"]
