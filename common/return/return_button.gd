extends Button

var down_img: Texture
var img: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()

func setup():
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pivot_offset = Vector2(size.x/2.0, size.y/2.0)
	focus_mode = FOCUS_NONE
	img = icon
	down_img = load("res://image/return2.png")

func _on_button_down() -> void:
	Main.play_btn_sfx()
	icon = down_img

func _on_button_up():
	icon = img
	
