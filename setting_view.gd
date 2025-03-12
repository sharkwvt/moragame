extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("esc"):
		queue_free()


func refresh():
	var music_db = Setting.setting_data[Setting.setting_music_key]
	var sound_db = Setting.setting_data[Setting.setting_sfx_key]
	$MusicLabel/MusicSlider.value = music_db
	$SoundLabel/SoundSlider.value = sound_db
	var is_fullscreen: bool = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED
	var popup: PopupMenu = $OptionButton.get_popup()
	popup.add_theme_font_size_override("font_size", 50) # 改字體大小


func _on_music_slider_value_changed(value: float) -> void:
	Setting.set_music_db(value)


func _on_sound_slider_value_changed(value: float) -> void:
	Setting.set_sound_db(value)


func _on_sound_slider_drag_ended(_value_changed: bool) -> void:
	$SoundLabel/SoundSlider/AudioStreamPlayer.play()


func _on_close_button_pressed() -> void:
	queue_free()


func _on_option_button_item_selected(index: int) -> void:
	Main.play_btn_sfx()
	Setting.set_screen_mode(index)


func _on_option_button_pressed() -> void:
	Main.play_btn_sfx()
