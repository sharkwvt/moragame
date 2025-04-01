extends Button

var lbl: Label
var textrue: TextureRect
var character_data: Main.CharacterData
var spine: SpineSprite


func set_data(data: Main.CharacterData):
	#lbl = $NameLabel
	#textrue = $Panel/Mask/TextureRect
	spine = $Control/SpineSprite
	var skel: SpineSkeleton = spine.get_skeleton()
	skel.set_skin_by_name(data.get_avatar_name())
	button_down.connect(_on_button_down)


func _on_button_down() -> void:
	Main.play_btn_sfx()
