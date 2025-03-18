extends Control
class_name CategoryScene

var category_btn = preload("res://scene/category/category_btn/category_btn.tscn")

var titles_dic: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_character_btns()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_character_btns():
	var categorys = Main.categorys_data
	var offset = size.x / (categorys.size()+1)
	var i = 0
	for data: Main.CategoryData in categorys:
		var btn: Button = category_btn.instantiate()
		btn.expand_icon = true
		btn.size = Vector2(150, 300)
		btn.text = data.category
		#var test_color = ColorRect.new()
		#test_color.set_anchors_preset(Control.PRESET_FULL_RECT)
		#btn.add_child(test_color)
		var title_lbl = Label.new()
		title_lbl.text = get_category_title(data)
		title_lbl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		title_lbl.add_theme_font_size_override("font_size", 20)
		titles_dic[data.category] = title_lbl
		btn.add_child(title_lbl)
		btn.position = Vector2(
			(i + 1) * offset - btn.size.x/2,
			500 - btn.size.y
		)
		# 綁定點擊事件
		btn.pressed.connect(_on_category_btn_pressed.bind(data))
		#btn.focus_mode = Control.FOCUS_NONE # 消除按鈕邊框
		add_child(btn)
		i += 1


func get_category_title(data: Main.CategoryData) -> String:
	var all_level = 0
	var progress: float = 0
	for c_data in data.characters:
		all_level += c_data.level
		progress += c_data.progress
	return data.category + " " + str(int(progress / all_level * 100)) + "%"


func refresh():
	#Main.reload_data()
	for c_data: Main.CategoryData in Main.categorys_data:
		(titles_dic[c_data.category] as Label).text = get_category_title(c_data)


func show_scene():
	refresh()


func _on_category_btn_pressed(data):
	Main.current_category_data = data
	Main.to_scene(Main.SCENE.menu)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)
