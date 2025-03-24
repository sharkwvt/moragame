extends Button
class_name MenuBtn

var character_data
var bonus_btn: Button
var has_bonus: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bonus_btn = $BonusButton

func set_data(data: Main.CharacterData):
	character_data = data
	$AvatarBG/Avatar.texture = load(data.get_avatar_path())
	$NameBG/NameLabel.text = data.display_name
	has_bonus = data.progress >= data.level


func lock():
	$Lock.visible = true
	$AvatarBG.visible = false
	$NameBG.visible = false
	$BonusButton.visible = false
	disabled = true


func open():
	$Lock.visible = false
	$AvatarBG.visible = true
	$NameBG.visible = true
	$BonusButton.visible = has_bonus
	disabled = false
