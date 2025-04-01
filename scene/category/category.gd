extends Control
class_name CategoryScene

var category_btn = preload("res://scene/category/category_btn/category_btn.tscn")

var btns = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_character_btns()
	Main.show_talk_view("選關對話")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_character_btns():
	var categorys = Main.categorys_data
	var spaceing = 140
	var offset = spaceing
	for i in categorys.size():
		var data: Main.CategoryData = categorys[i]
		var btn: Button = category_btn.instantiate()
		var img_path = "res://scene/category/category_btn/image/"
		btn.texture_n = load(img_path + "building_" + str(i) + "_n.png")
		btn.texture_light = load(img_path + "building_" + str(i) + ".png")
		btn.texture_halo = load(img_path + "building_" + str(i) + "_halo.png")
		btn.set_data(data)
		btn.position = Vector2.ZERO # 不知為何這樣才能取到size
		btn.position = Vector2(
			offset,
			size.y * 0.7 - btn.size.y
		)
		offset += btn.size.x + spaceing
		if i > 0:
			var temp: Main.CategoryData = categorys[i-1]
			btn.is_lock = temp.progress != temp.all_level or temp.all_level == 0
			btn.disabled = btn.is_lock
		# 綁定點擊事件
		btn.pressed.connect(_on_category_btn_pressed.bind(data))
		btns.append(btn)
		add_child(btn)


func refresh():
	#Main.reload_data()
	for i in Main.categorys_data.size():
		btns[i].set_data(Main.categorys_data[i])


func show_scene():
	refresh()
	Main.show_talk_view("選關對話")


func _on_category_btn_pressed(data):
	Main.current_category_data = data
	Main.to_scene(Main.SCENE.menu, 2)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)
