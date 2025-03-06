extends Control
class_name StartScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.instance_scenes[Main.SCENE.start] = self
	Main.play_music(Main.music_1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func show_scene():
	move_to_front()


func _on_start_button_pressed() -> void:
	Main.to_scene(Main.SCENE.menu)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()
