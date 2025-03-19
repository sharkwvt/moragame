extends Button

var img_n
var img_s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mouse_entered():
	icon = img_s


func _on_mouse_exited():
	icon = img_n


func _on_button_down() -> void:
	Main.play_btn_sfx()
