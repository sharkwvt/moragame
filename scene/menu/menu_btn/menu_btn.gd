extends Button
class_name MenuBtn

var index:int
var character_data: Main.CharacterData
var bonus_btn: Button
var avatar_btn: Button
var is_open: bool
var can_bonus: bool
var avatar_spine: SpineSprite
var lock_sp: SpineSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bonus_btn = $BonusButton
	avatar_btn = $Avatar/AvatarButton
	lock_sp = $Lock/SpineSprite
	var anim: SpineAnimationState = lock_sp.get_animation_state()
	anim.set_animation("lock_a", false)
	anim.set_time_scale(0)

func set_data(category_data: Main.CategoryData, data: Main.CharacterData):
	avatar_spine = $Avatar/SpineSprite
	character_data = data
	#$AvatarBG/Avatar.texture = load(data.get_avatar_path())
	#$NameBG/NameLabel.text = data.display_name
	avatar_spine.skeleton_data_res = load(category_data.get_avatar_path())
	can_bonus = data.progress >= data.level and data.level > 0
	var skel: SpineSkeleton = avatar_spine.get_skeleton()
	skel.set_skin_by_name(character_data.get_avatar_name())


func lock():
	$Lock.visible = true
	#$AvatarBG.visible = false
	#$NameBG.visible = false
	$Avatar/SpineSprite.visible = false
	$BonusButton.visible = false
	is_open = false


func open():
	$Lock.visible = false
	#$AvatarBG.visible = true
	#$NameBG.visible = true
	$Avatar/SpineSprite.visible = true
	$BonusButton.visible = can_bonus if character_data.get_spine_path() != "" else false
	is_open = true


func play_unlock_anim():
	lock_sp.get_animation_state().set_time_scale(1)
	await lock_sp.animation_completed
	open()
	play_animation()


func play_animation():
	var anim: SpineAnimationState = avatar_spine.get_animation_state()
	anim.set_animation("photo_gir", false)
