extends Button
class_name MenuBtn

@export var avatar_btn: Button
@export var avatar_spine: SpineSprite
@export var lock_view: Control
@export var lock_sp: SpineSprite

var index:int
var character_data: CharacterData
var is_open: bool
var can_bonus: bool
var to_bonus: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim: SpineAnimationState = lock_sp.get_animation_state()
	anim.set_animation("lock_a", false)
	anim.set_time_scale(0)

func set_data(_category_data: CategoryData, data: CharacterData):
	character_data = data
	#$AvatarBG/Avatar.texture = load(data.get_avatar_path())
	#$NameBG/NameLabel.text = data.display_name
	#avatar_spine.skeleton_data_res = load(category_data.get_avatar_path())
	can_bonus = data.progress >= data.level and data.level > 0
	to_bonus = false
	set_avatar_skin()


func lock():
	lock_view.visible = true
	avatar_spine.visible = false
	is_open = false


func open():
	lock_view.visible = false
	avatar_spine.visible = true
	#bonus_btn.visible = can_bonus if character_data.get_spine_path() != "" else false
	is_open = true


func play_unlock_anim():
	lock_sp.get_animation_state().set_time_scale(1)
	await lock_sp.animation_completed
	open()
	var anim: SpineAnimationState = avatar_spine.get_animation_state()
	anim.set_animation("photo_gir", false)


func set_avatar_skin():
	var skin = character_data.get_avatar_name()
	if can_bonus:
		skin += "2" if to_bonus else "1"
	var skel: SpineSkeleton = avatar_spine.get_skeleton()
	skel.set_skin_by_name(skin)


func on_click_avatar():
	to_bonus = !to_bonus
	set_avatar_skin()
	var anim: SpineAnimationState = avatar_spine.get_animation_state()
	anim.set_animation("click", false)
