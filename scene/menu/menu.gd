extends Control
class_name MenuScene

var cs_list_view = preload("res://scene/menu/menu_cs_list.tscn")

var categorys = []
var menu_dic: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_menu_dic()
	create_test_data() # 測試用資料
	create_characters_btns()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_menu_dic():
	var characters_data: Array = Main.characters_data
	if characters_data:
		for character: Main.CharacterData in characters_data:
			var category = character.category
			if category not in menu_dic.keys():
				categorys.append(category)
				menu_dic[category] = []
			menu_dic[category].append(character)


func create_test_data():
	if categorys.size() > 0:
		for category in categorys:
			for i in 10:
				var data = Main.CharacterData.new()
				data.id = 99
				data.category = "where"
				data.display_name = "who"
				data.file_name = "test"
				data.level = 2
				data.story = ["test1", "test2", "test3"]
				menu_dic[category].append(data)


func create_characters_btns():
	var btn_size = Vector2(150, 150)
	var offset = 10 # 按鈕間隔
	for key in menu_dic.keys():
		var i = 0
		var list_view = cs_list_view.instantiate()
		list_view.get_node("btns_panel/Label").text = key # 主題
		var btns_panel = list_view.get_node("btns_panel") # 按鈕列表
		var h_count = floori(btns_panel.size.x / (btn_size.x + offset))
		add_child(list_view)
		for data: Main.CharacterData in menu_dic[key]:
			var btn = CommonButton.new()
			var img_path = "res://characters/" + data.file_name + "/" + data.file_name + "_" + str(1) + ".jpg"
			btn.icon = load(img_path)
			btn.expand_icon = true
			btn.size = btn_size
			var lbl = Label.new()
			lbl.text = str(data.progress)
			btn.add_child(lbl)
			btn.position = Vector2(
				(btns_panel.size.x - btn.size.x)/2.0 + (i%h_count - (h_count-1)/2.0) * (btn.size.x + offset),
				#offset + floor(i/h_count) * (btn.size.y + offset)
				(btns_panel.size.y - btn.size.y)/2.0 + (floor(i/h_count) - (floor(menu_dic[key].size()/h_count)-1)/2.0) * (btn.size.y + offset),
			)
			# 綁定點擊事件
			btn.connect("pressed", Callable(self, "_on_characters_btn_pressed").bind(data))
			btn.focus_mode = Control.FOCUS_NONE
			btns_panel.add_child(btn)
			i += 1
	


func show_scene():
	pass


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)


func _on_characters_btn_pressed(data: Main.CharacterData) -> void:
	Main.current_character_data = data
	Main.to_scene(Main.SCENE.game)
