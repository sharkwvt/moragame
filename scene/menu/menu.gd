extends Control
class_name MenuScene

var menu_dic = {
	第一列 = [{progress = 0}, {progress = 0}, {progress = 0}],
	第二列 = [{progress = 0}, {progress = 0}, {progress = 0}]
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func show_scene():
	move_to_front()


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)
