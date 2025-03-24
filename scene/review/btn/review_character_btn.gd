extends Button

var lbl: Label
var textrue: TextureRect
var character_data: Main.CharacterData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()


func setup():
	lbl = $NameLabel
	textrue = $Panel/Mask/TextureRect
	button_down.connect(_on_button_down)


func _on_button_down() -> void:
	Main.play_btn_sfx()
