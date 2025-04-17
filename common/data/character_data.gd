extends Object
class_name CharacterData

var id = 0
var display_name: String
var file_name: String
var category: String
var level: int
var story: Array
var progress = 0
var has_bonus = false

func get_path() -> String:
	return "res://categorys/" + category + "/characters/sex_girl_" + file_name

func get_avatar_name() -> String:
	return "photo_girl_" + file_name

func get_cg_path(index) -> String:
	return get_path() + "/sex_girl_" + file_name + "_lv" + str(index+1) + ".png"

func get_spine_path() -> String:
	var path = get_path() + "/spine/" + file_name + ".tres"
	return path if FileAccess.file_exists(path) else ""
