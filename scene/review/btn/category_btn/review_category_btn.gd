extends ButtonEx
class_name ReviewCategoryBtn

@export var lbl: LabelEx
@export var dlc_view: TextureRect
@export var img_n: Texture
@export var img_s: Texture

var data: CategoryData

func set_data(c_data: CategoryData):
	data = c_data
	lbl.text = tr(c_data.category_title) + " " + c_data.get_progress_str()
	dlc_view.visible = !c_data.has_dlc
