extends Button
class_name MenuBtn

var character_data
var bonus_btn: Button
var is_open: bool
var has_bonus: bool
var avatar_spine: SpineSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bonus_btn = $BonusButton

func set_data(data: Main.CharacterData):
	avatar_spine = $Control/SpineSprite
	character_data = data
	#$AvatarBG/Avatar.texture = load(data.get_avatar_path())
	#$NameBG/NameLabel.text = data.display_name
	has_bonus = data.progress >= data.level and data.level > 0
	var skel: SpineSkeleton = avatar_spine.get_skeleton()
	skel.set_skin_by_name(data.get_avatar_name())


func lock():
	$Lock.visible = true
	#$AvatarBG.visible = false
	#$NameBG.visible = false
	avatar_spine.visible = false
	$BonusButton.visible = false
	is_open = false


func open():
	$Lock.visible = false
	#$AvatarBG.visible = true
	#$NameBG.visible = true
	avatar_spine.visible = true
	$BonusButton.visible = has_bonus
	is_open = true
	
	var anim: SpineAnimationState = avatar_spine.get_animation_state()
	anim.set_animation("photo_gir", false)
