extends Button
class_name MenuBtn

var character_data
var has_bonus: bool

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


func _on_pressed(is_bonus) -> void:
	Main.current_character_data = character_data
	Main.to_scene(Main.SCENE.game)
	Main.instance_scenes[Main.SCENE.game].is_bonus = is_bonus
