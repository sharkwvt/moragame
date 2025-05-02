extends Object
class_name CharacterData

var id = 0
var display_name: String
var file_name: String
var category: String
var level: int
var progress = 0
var has_bonus = false
var has_dlc: bool

func get_path() -> String:
	return "res://categorys/" + category + "/characters/sex_girl_" + file_name

func get_avatar_name() -> String:
	return "photo_girl_" + file_name

func get_cg_path(index) -> String:
	var img_name = "sex_girl_" + file_name + "_lv" + str(index+1) + ".png"
	return get_path().path_join(img_name)

func get_spine_path() -> String:
	var spine_name = file_name + ".tres"
	var path = get_path().path_join("spine").path_join(spine_name)
	return path if FileAccess.file_exists(path) else ""

func check_dlc():
	has_dlc = get_spine_path() != ""
