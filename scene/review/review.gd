extends Scene

@export var phone: TextureRect

var category_list_btn = preload("res://scene/review/btn/review_category_btn.tscn")

var category_list_panel: Panel
var category_list_btns = []
var character_btns = []
var character_lbls = []

var review_imgs = []
var review_view: ColorRect
var review_img: TextureRect
var review_spine: SpineSpriteEx
var view_index = 0

var selected_category: CategoryData
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	create_category_btns()
	play_start_anim()
	await tween.finished
	_on_category_btn_pressed(0) # 開第一個


func setup():
	category_list_panel = $Phone/CategoryList
	character_btns.append($Characters/RCBtn)
	character_btns.append($Characters/RCBtn2)
	character_btns.append($Characters/RCBtn3)
	character_btns.append($Characters/RCBtn4)
	character_btns.append($Characters/RCBtn5)
	for i in character_btns.size():
		var btn: Button = character_btns[i]
		btn.pressed.connect(_on_character_button_pressed.bind(i))
	review_view = $View
	review_img = $View/TextureRect
	review_spine = $View/Spine/SpineSprite
	review_view.visible = false
	review_spine.visible = false


func play_start_anim():
	tween = create_tween()
	tween.tween_property(phone, "position", phone.position, 1)
	phone.position.y += phone.size.y


func show_review(data: CharacterData):
	review_view.visible = true
	load_imgs(data)
	review_img.texture = review_imgs[view_index]


func create_category_btns():
	var offset_y = 20
	for i in Main.categorys_data.size():
		var category_data: CategoryData = Main.categorys_data[i]
		var btn: Button = category_list_btn.instantiate()
		btn.text = tr(category_data.category) + " " + category_data.get_progress_str()
		btn.position = Vector2(
			0,
			offset_y + i * (btn.size.y + offset_y)
		)
		btn.pressed.connect(_on_category_btn_pressed.bind(i))
		category_list_panel.add_child(btn)
		category_list_btns.append(btn)


func load_imgs(data: CharacterData):
	review_imgs.clear()
	for i in data.story.size():
		review_imgs.append(load(data.get_cg_path(i)))
	if not data.has_bonus:
		return
	review_spine.skeleton_data_res = load(data.get_spine_path())
	review_spine.play_first_anim()


func refresh_characters():
	for i in character_btns.size():
		var btn: Button = character_btns[i]
		if i >= selected_category.characters.size():
			btn.visible = false
			continue
		var data: CharacterData = selected_category.characters[i]
		btn.visible = data.progress >= data.level
		btn.set_data(selected_category, data)


func refresh():
	# 更新主題按鈕
	for i in Main.categorys_data.size():
		var category_data: CategoryData = Main.categorys_data[i]
		var btn = category_list_btns[i]
		btn.text = category_data.category + " " + category_data.get_progress_str()
		btn.button_pressed = false


func show_scene():
	refresh()
	_on_category_btn_pressed(0)

func return_scene():
	Main.to_scene(Main.SCENE.start)


func _on_category_btn_pressed(index):
	Main.play_btn_sfx()
	for btn: Button in category_list_btns:
		btn.button_pressed = false
	category_list_btns[index].button_pressed = true
	selected_category = Main.categorys_data[index]
	refresh_characters()


func _on_return_button_pressed() -> void:
	return_scene()


func _on_character_button_pressed(extra_arg_0: int) -> void:
	var data = selected_category.characters[extra_arg_0]
	show_review(data)


func _on_view_button_pressed() -> void:
	view_index += 1
	if view_index < review_imgs.size():
		review_img.texture = review_imgs[view_index]
	elif view_index == review_imgs.size() and review_spine.skeleton_data_res:
		# 顯示spine
		review_img.visible = false
		review_spine.visible = true
	else:
		# 關閉
		review_view.visible = false
		# 初始化
		review_img.visible = true
		review_spine.visible = false
		view_index = 0
	
