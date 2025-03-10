extends Button
class_name CommonButton

var btn_sfx = preload("res://sound/maou_se_system47.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_down() -> void:
	Main.play_sfx(btn_sfx)
