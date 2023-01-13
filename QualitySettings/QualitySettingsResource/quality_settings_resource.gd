class_name QualitySettingsResource
extends Resource

enum SCALING_3D_MODE {
	BILINEAR = Viewport.SCALING_3D_MODE_BILINEAR,
	FSR = Viewport.SCALING_3D_MODE_FSR,
}

enum VSYNC_MODE {
	DISABLED = DisplayServer.VSYNC_DISABLED,
	ADAPTIVE = DisplayServer.VSYNC_ADAPTIVE,
	ENABLED = DisplayServer.VSYNC_ENABLED,
}

enum MSAA_3D_MODE {
	DISABLED = Viewport.MSAA_DISABLED,
	MSAA_2X = Viewport.MSAA_2X,
	MSAA_4X = Viewport.MSAA_4X,
	MSAA_8X = Viewport.MSAA_8X,
}

enum SS_REFLECTION_QUALITY {
	DISABLED = 0,
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
}

enum SSAO_QUALITY {
	DISABLED = 0,
	VERY_LOW = 1,
	LOW = 2,
	MEDIUM = 3,
	HIGH = 4,
}

enum SSIL_QUALITY {
	DISABLED = 0,
	VERY_LOW = 1,
	LOW = 2,
	MEDIUM = 3,
	HIGH = 4,
}

enum SDFGI_QUALITY {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

enum GLOW_QUALITY {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

enum VOLUMETRIC_FOG_QUALITY {
	DISABLED = 0,
	LOW = 1,
	HIGH = 2,
}

const SS_REFLECTION_ENVIRONMENT_SETTINGS := {
	SS_REFLECTION_QUALITY.DISABLED: {
		"enabled": false,
		"max_steps": 8,
	},
	SS_REFLECTION_QUALITY.LOW: {
		"enabled": true,
		"max_steps": 8,
	},
	SS_REFLECTION_QUALITY.MEDIUM: {
		"enabled": true,
		"max_steps": 32,
	},
	SS_REFLECTION_QUALITY.HIGH: {
		"enabled": true,
		"max_steps": 56,
	},
}

const SSAO_ENVIRONMENT_SETTINGS := {
	SSAO_QUALITY.DISABLED: {
		"enabled": false,
		"ssao_quality": {
			"quality": RenderingServer.ENV_SSAO_QUALITY_VERY_LOW,
			"settings": [true, 0.5, 2, 50, 300]
		},
	},
	SSAO_QUALITY.VERY_LOW: {
		"enabled": true,
		"ssao_quality": {
			"quality": RenderingServer.ENV_SSAO_QUALITY_VERY_LOW,
			"settings": [true, 0.5, 2, 50, 300]
		},
	},
	SSAO_QUALITY.LOW: {
		"enabled": true,
		"ssao_quality": {
			"quality": RenderingServer.ENV_SSAO_QUALITY_LOW,
			"settings": [true, 0.5, 2, 50, 300]
		},
	},
	SSAO_QUALITY.MEDIUM: {
		"enabled": true,
		"ssao_quality": {
			"quality": RenderingServer.ENV_SSAO_QUALITY_MEDIUM,
			"settings": [true, 0.5, 2, 50, 300]
		},
	},
	SSAO_QUALITY.HIGH: {
		"enabled": true,
		"ssao_quality": {
			"quality": RenderingServer.ENV_SSAO_QUALITY_HIGH,
			"settings": [true, 0.5, 2, 50, 300]
		},
	},
}

const SSIL_ENVIRONMENT_SETTINGS := {
	SSIL_QUALITY.DISABLED: {
		"enabled": false,
		"ssil_quality": {
			"quality": RenderingServer.ENV_SSIL_QUALITY_VERY_LOW,
			"settings": [true, 0.5, 4, 50, 300],
		},
	},
	SSIL_QUALITY.VERY_LOW: {
		"enabled": true,
		"ssil_quality": {
			"quality": RenderingServer.ENV_SSIL_QUALITY_VERY_LOW,
			"settings": [true, 0.5, 4, 50, 300],
		},
	},
	SSIL_QUALITY.LOW: {
		"enabled": true,
		"ssil_quality": {
			"quality": RenderingServer.ENV_SSIL_QUALITY_LOW,
			"settings": [true, 0.5, 4, 50, 300],
		},
	},
	SSIL_QUALITY.MEDIUM: {
		"enabled": true,
		"ssil_quality": {
			"quality": RenderingServer.ENV_SSIL_QUALITY_MEDIUM,
			"settings": [true, 0.5, 4, 50, 300],
		},
	},
	SSIL_QUALITY.HIGH: {
		"enabled": true,
		"ssil_quality": {
			"quality": RenderingServer.ENV_SSIL_QUALITY_HIGH,
			"settings": [true, 0.5, 4, 50, 300],
		},
	},
}

const SDFGI_ENVIRONMENT_SETTINGS := {
	SDFGI_QUALITY.DISABLED: {
		"enabled": false,
		"use_half_resolution": true
	},
	SDFGI_QUALITY.LOW: {
		"enabled": true,
		"use_half_resolution": true
	},
	SDFGI_QUALITY.HIGH: {
		"enabled": true,
		"use_half_resolution": false
	},
}

const GLOW_ENVIRONMENT_SETTINGS := {
	GLOW_QUALITY.DISABLED: {
		"enabled": false,
		"use_bicubic_upscale": false
	},
	GLOW_QUALITY.LOW: {
		"enabled": true,
		"use_bicubic_upscale": false
	},
	GLOW_QUALITY.HIGH: {
		"enabled": true,
		"use_bicubic_upscale": true
	},
}

const VOLUMETRIC_FOG_ENVIRONMENT_SETTINGS := {
	VOLUMETRIC_FOG_QUALITY.DISABLED: {
		"enabled": false,
		"filter_active": false,
	},
	VOLUMETRIC_FOG_QUALITY.LOW: {
		"enabled": true,
		"filter_active": false,
	},
	VOLUMETRIC_FOG_QUALITY.HIGH: {
		"enabled": true,
		"filter_active": true,
	},
}

@export var viewport_start_size = Vector2(1152, 648)
@export_range(0.25, 2.0, 0.05) var scaling_3d_value = 1.0
@export var scaling_3d_mode: SCALING_3D_MODE = 0
@export var vsync_mode: VSYNC_MODE = 0
@export var msaa_3d_mode: MSAA_3D_MODE = MSAA_3D_MODE.DISABLED
@export var fxaa_enabled: bool = false
#@export var fullscreen_enabled: bool = false
@export var ss_reflection_quality: SS_REFLECTION_QUALITY = 0
@export var ssao_quality: SSAO_QUALITY = 0
@export var ssil_quality: SSIL_QUALITY = 0
@export var sdfgi_quality: SDFGI_QUALITY = 0
@export var glow_quality: GLOW_QUALITY = 0
@export var volumetric_fog_quality: VOLUMETRIC_FOG_QUALITY = 0
@export_range(0.5, 4.0, 0.05) var brightness_value = 1.0
@export_range(0.5, 4.0, 0.05) var contrast_value = 1.0
@export_range(0.5, 10.0, 0.05) var saturation_value = 1.0

var ss_reflection_environment_settings : Dictionary :
	get:
		return SS_REFLECTION_ENVIRONMENT_SETTINGS[ss_reflection_quality]

var ssao_environment_settings : Dictionary :
	get:
		return SSAO_ENVIRONMENT_SETTINGS[ssao_quality]

var ssil_environment_settings : Dictionary :
	get:
		return SSIL_ENVIRONMENT_SETTINGS[ssil_quality]

var sdfgi_environment_settings : Dictionary :
	get:
		return SDFGI_ENVIRONMENT_SETTINGS[sdfgi_quality]

var glow_environment_settings : Dictionary :
	get:
		return GLOW_ENVIRONMENT_SETTINGS[glow_quality]

var volumetric_fog_environment_settings : Dictionary :
	get:
		return VOLUMETRIC_FOG_ENVIRONMENT_SETTINGS[volumetric_fog_quality]


func apply_settings(viewport: Viewport, environment: Environment) -> void:
	viewport.scaling_3d_scale = scaling_3d_value
	viewport.scaling_3d_mode = scaling_3d_mode

	# ISSUE: https://github.com/godotengine/godot/issues/70837
	DisplayServer.window_set_vsync_mode(vsync_mode)

	viewport.msaa_3d = msaa_3d_mode

	viewport.screen_space_aa = fxaa_enabled

	environment.set_ssr_enabled(ss_reflection_environment_settings["enabled"])
	environment.set_ssr_max_steps(ss_reflection_environment_settings["max_steps"])

	var ssao_settings = ssao_environment_settings["ssao_quality"]
	var ssao_server_settings = ssao_settings["settings"]

	environment.ssao_enabled = ssao_environment_settings["enabled"]
	RenderingServer.environment_set_ssao_quality(ssao_settings["quality"], ssao_server_settings[0], ssao_server_settings[1], ssao_server_settings[2], ssao_server_settings[3], ssao_server_settings[4])

	var ssil_settings = ssil_environment_settings["ssil_quality"]
	var ssil_server_settings = ssil_settings["settings"]

	environment.ssil_enabled = ssil_environment_settings["enabled"]
	RenderingServer.environment_set_ssil_quality(ssil_settings["quality"], ssil_server_settings[0], ssil_server_settings[1], ssil_server_settings[2], ssil_server_settings[3], ssil_server_settings[4])

	environment.sdfgi_enabled = sdfgi_environment_settings["enabled"]
	RenderingServer.gi_set_use_half_resolution(sdfgi_environment_settings["use_half_resolution"])

	environment.glow_enabled = glow_environment_settings["enabled"]
	RenderingServer.environment_glow_set_use_bicubic_upscale(glow_environment_settings["use_bicubic_upscale"])

	environment.volumetric_fog_enabled = volumetric_fog_environment_settings["enabled"]
	RenderingServer.environment_set_volumetric_fog_filter_active(volumetric_fog_environment_settings["filter_active"])

	environment.set_adjustment_brightness(brightness_value)
	environment.set_adjustment_contrast(contrast_value)
	environment.set_adjustment_saturation(saturation_value)
