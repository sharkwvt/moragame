extends Control
class_name MenuScene

class BtnData:
	var progress = 0
	var img
	
var menu_dic: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_test_data() # 測試用資料
	
	for key in menu_dic.keys():
		for data: BtnData in menu_dic[key]:
			var btn = CommonButton.new()
			btn.icon = load(data.img)
			btn.size = Vector2(100, 100)
			var lbl = Label.new()
			lbl.text = str(data.progress)
			btn.add_child(lbl)
			$"第一列/HBoxContainer".add_child(btn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_test_data():
	var arr1 = []
	for i in 10:
		var data = BtnData.new()
		data.img = "res://scene/menu/btns/btn.png"
		arr1.append(data)
	menu_dic["第一列"] = arr1
	
	var arr2 = []
	for i in 5:
		var data = BtnData.new()
		data.img = "res://scene/menu/btns/btn.png"
		arr2.append(data)
	menu_dic["第二列"] = arr2


func show_scene():
	visible = true
	move_to_front()


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)
