extends ButtonEx

var lbl: Label
var textrue: TextureRect
var character_data: CharacterData
var spine: SpineSprite

func set_data(_category_data: CategoryData, data: CharacterData):
	#lbl = $NameLabel
	#textrue = $Panel/Mask/TextureRect
	spine = $Avatar/SpineSprite
	#spine.skeleton_data_res = load(category_data.get_avatar_path())
	var skel: SpineSkeleton = spine.get_skeleton()
	skel.set_skin_by_name(data.get_avatar_name())
