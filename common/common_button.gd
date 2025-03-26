extends Button
class_name CommonButton



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)
	pivot_offset = Vector2(size.x/2.0, size.y/2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_down() -> void:
	Main.play_btn_sfx()
