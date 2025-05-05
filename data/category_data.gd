extends Object
class_name CategoryData

var id: int
var category: String
var category_title: String
var category_desc: String
var characters = []
var all_level: int
var progress: float
var path: String
var menu: PackedScene

func get_img_path(type) -> String:
	var name = "building"
	match type:
		0:
			name += "_n"
		1:
			name += "_s"
		2:
			name += "_halo"
	name += ".png"
	return path.path_join("btn").path_join(name)


func get_progress_str() -> String:
	all_level = 0
	progress = 0
	for c_data in characters:
		all_level += c_data.level
		progress += c_data.progress
	if all_level == 0:
		return "🔒"
	return str(int(progress / all_level * 100)) + "%"


func get_menu_path() -> String:
	return path + "/menu/menu.tscn"
