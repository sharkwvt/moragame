extends Control
class_name MenuScene

var cs_list_view = preload("res://scene/menu/menu_cs_list.tscn")

var categorys = []
var menu_dic: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_menu_dic()
	create_test_data() # 測試用資料
	#for key in menu_dic.keys():
		#for data: BtnData in menu_dic[key]:
			#var btn = CommonButton.new()
			#btn.icon = load(data.img)
			#btn.size = Vector2(100, 100)
			#var lbl = Label.new()
			#lbl.text = str(data.progress)
			#btn.add_child(lbl)
			#$"第一列/HBoxContainer".add_child(btn)


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
				data.name = "who"
				data.img = "res://scene/menu/btns/btn.png"
				menu_dic[category].append(data)


func show_scene():
	pass


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)


func _on_common_button_pressed() -> void:
	Main.current_character_data = menu_dic[categorys[0]][0]
	Main.to_scene(Main.SCENE.game)
