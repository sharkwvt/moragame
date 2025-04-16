extends Button
class_name MenuBtn

@export var avatar_btn: Button
@export var avatar_spine: SpineSprite
@export var bonus_btn: Button
@export var lock_view: Control
@export var lock_sp: SpineSprite

var index:int
var character_data: Main.CharacterData
var is_open: bool
var can_bonus: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim: SpineAnimationState = lock_sp.get_animation_state()
	anim.set_animation("lock_a", false)
	anim.set_time_scale(0)

func set_data(category_data: Main.CategoryData, data: Main.CharacterData):
	character_data = data
	#$AvatarBG/Avatar.texture = load(data.get_avatar_path())
	#$NameBG/NameLabel.text = data.display_name
	avatar_spine.skeleton_data_res = load(category_data.get_avatar_path())
	can_bonus = data.progress >= data.level and data.level > 0
	var skel: SpineSkeleton = avatar_spine.get_skeleton()
	skel.set_skin_by_name(character_data.get_avatar_name())


func lock():
	lock_view.visible = true
	#$AvatarBG.visible = false
	#$NameBG.visible = false
	avatar_spine.visible = false
	bonus_btn.visible = false
	is_open = false


func open():
	lock_view.visible = false
	#$AvatarBG.visible = true
	#$NameBG.visible = true
	avatar_spine.visible = true
	bonus_btn.visible = can_bonus if character_data.get_spine_path() != "" else false
	is_open = true


func play_unlock_anim():
	lock_sp.get_animation_state().set_time_scale(1)
	await lock_sp.animation_completed
	open()
	play_animation()


func play_animation():
	var anim: SpineAnimationState = avatar_spine.get_animation_state()
	anim.set_animation("photo_gir", false)
