extends Node

var config = ConfigFile.new()
var setting_path = "user://setting.cfg"
var setting_section = "setting"

var setting_music_key = "MUSIC"
var setting_sfx_key = "SFX"
var setting_screen_key = "SCREEN_MODE"
var setting_data: Dictionary = {}

enum SCREEN_MODE {
	視窗720p,
	視窗1080p,
	無邊框全螢幕,
	全螢幕
}

func _init() -> void:
	setting_data[setting_music_key] = 0.5
	setting_data[setting_sfx_key] = 0.5
	setting_data[setting_screen_key] = SCREEN_MODE.視窗720p  # 預設
	load_setting()
	set_music_db(setting_data[setting_music_key])
	set_sound_db(setting_data[setting_sfx_key])
	set_screen_mode(setting_data[setting_screen_key])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func load_setting():
	var err = config.load(setting_path)
	if err != OK:
		reset_setting()
		return
	for key in setting_data.keys():
		if config.has_section_key(setting_section, key):
			setting_data[key] = config.get_value(setting_section, key)


func set_setting(key, value):
	setting_data[key] = value
	config.set_value(setting_section, key, value)
	config.save(setting_path)


func reset_setting():
	config.clear()
	config.save(setting_path)


func set_music_db(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 60 * (value - 1))
	set_setting(setting_music_key, value)


func set_sound_db(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 60 * (value - 1))
	set_setting(setting_sfx_key, value)


func set_screen_mode(mode: SCREEN_MODE):
	match mode:
		SCREEN_MODE.視窗720p:
			DisplayServer.window_set_size(Vector2i(1280, 720))
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			center_window()
		SCREEN_MODE.視窗1080p:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			center_window()
		SCREEN_MODE.無邊框全螢幕:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		SCREEN_MODE.全螢幕:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	set_setting(setting_screen_key, mode)
	
# 視窗置中
func center_window():
	var screen_size = DisplayServer.screen_get_size(0)
	var window_size = DisplayServer.window_get_size()
	var new_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_position)
