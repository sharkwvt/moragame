extends Button

var lbl: Label
var textrue: TextureRect
var character_data: CharacterData
var spine: SpineSprite

func _ready() -> void:
	button_down.connect(_on_button_down)

func set_data(_category_data: CategoryData, data: CharacterData):
	#lbl = $NameLabel
	#textrue = $Panel/Mask/TextureRect
	spine = $Avatar/SpineSprite
	#spine.skeleton_data_res = load(category_data.get_avatar_path())
	var skel: SpineSkeleton = spine.get_skeleton()
	skel.set_skin_by_name(data.get_avatar_name())


func _on_button_down() -> void:
	Main.play_btn_sfx()
