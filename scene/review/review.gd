extends Control

var category_list_btn = preload("res://scene/review/btn/review_category_btn.tscn")

var category_list_panel: Panel
var category_list_btns = []
var character_btns = []
var character_lbls = []

var selected_category: Main.CategoryData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	create_category_btns()
	_on_category_btn_pressed(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	category_list_panel = $Phone/CategoryList
	character_btns.append($Panel/Mask/CommonButton)
	character_btns.append($Panel2/Mask/CommonButton)
	character_btns.append($Panel3/Mask/CommonButton)
	character_btns.append($Panel4/Mask/CommonButton)
	character_btns.append($Panel5/Mask/CommonButton)
	character_lbls.append($Panel/NameLabel)
	character_lbls.append($Panel2/NameLabel)
	character_lbls.append($Panel3/NameLabel)
	character_lbls.append($Panel4/NameLabel)
	character_lbls.append($Panel5/NameLabel)


func create_category_btns():
	var offset_y = 20
	for i in Main.categorys_data.size():
		var category_data: Main.CategoryData = Main.categorys_data[i]
		var btn: Button = category_list_btn.instantiate()
		btn.text = category_data.category + " " + category_data.get_progress_str()
		btn.position = Vector2(
			0,
			offset_y + i * (btn.size.y + offset_y)
		)
		btn.pressed.connect(_on_category_btn_pressed.bind(i))
		category_list_panel.add_child(btn)
		category_list_btns.append(btn)


func refresh_characters():
	for i in character_btns.size():
		var data: Main.CharacterData = selected_category.characters[i]
		var btn: Button = character_btns[i]
		var lbl: Label = character_lbls[i]
		btn.icon = load(data.get_avatar_path())
		btn.disabled = data.progress < data.level
		lbl.text = data.display_name


func refresh():
	# 更新主題按鈕
	for i in Main.categorys_data.size():
		var category_data: Main.CategoryData = Main.categorys_data[i]
		var btn = category_list_btns[i]
		btn.text = category_data.category + " " + category_data.get_progress_str()
		btn.button_pressed = false


func show_scene():
	refresh()
	_on_category_btn_pressed(0)


func _on_category_btn_pressed(index):
	Main.play_btn_sfx()
	for btn: Button in category_list_btns:
		btn.button_pressed = false
	category_list_btns[index].button_pressed = true
	selected_category = Main.categorys_data[index]
	refresh_characters()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.start)


func _on_character_button_pressed(extra_arg_0: int) -> void:
	var data = selected_category.characters[extra_arg_0]
