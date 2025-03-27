extends Control
class_name CategoryScene

var category_btn = preload("res://scene/category/category_btn/category_btn.tscn")

var btns = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_character_btns()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_character_btns():
	var categorys = Main.categorys_data
	var spaceing = 100
	var offset = spaceing
	var i = 0
	for data: Main.CategoryData in categorys:
		var btn := category_btn.instantiate()
		btn.img_n = load("res://scene/category/category_btn/select_" + str(i) + "_n.png")
		btn.img_s = load("res://scene/category/category_btn/select_" + str(i) + ".png")
		btn.icon = btn.img_n
		btn.set_data(data)
		btn.position = Vector2.ZERO # 不知為何這樣才能取到size
		btn.position = Vector2(
			offset,
			size.y * 0.7 - btn.size.y
		)
		offset += btn.size.x + spaceing
		# 綁定點擊事件
		btn.pressed.connect(_on_category_btn_pressed.bind(data))
		btns.append(btn)
		add_child(btn)
		i += 1


func refresh():
	#Main.reload_data()
	for i in Main.categorys_data.size():
		btns[i].set_data(Main.categorys_data[i])


func show_scene():
	refresh()


func _on_category_btn_pressed(data):
	Main.current_category_data = data
	Main.to_scene(Main.SCENE.menu, 2)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)
