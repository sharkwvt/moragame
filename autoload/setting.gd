extends Node

var config = ConfigFile.new()
var setting_path = "user://setting.cfg"
var setting_section = "setting"

var setting_music_key = "music"
var setting_sfx_key = "sfx"
var setting_data: Dictionary = {}


func _init() -> void:
	setting_data[setting_music_key] = 0.5
	setting_data[setting_sfx_key] = 0.5
	load_setting()
	set_music_db(setting_data[setting_music_key])
	set_sound_db(setting_data[setting_sfx_key])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func load_setting():
	var err = config.load(setting_path)
	if err != OK:
		reset_setting()
		return
	for key in setting_data.keys():
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
