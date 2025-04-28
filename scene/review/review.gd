extends Scene

@export var phone: TextureRect

@export var category_btn: PackedScene
@export var character_btn: PackedScene

@export var categorys_view: Panel
@export var characters_view: Control
@export var cg_view_root: NinePatchRect
@export var cg_btns_view: Control
@export var cg_view_btn: ButtonEx
@export var cg_spine: SpineSpriteEx
@export var full_view: ColorRect
@export var full_view_img: TextureRect
@export var full_view_spine: SpineSpriteEx

@export var play_icon: Texture

var category_list_btns = []
var character_btns = []
var cg_btns = []

var review_imgs = []
var skeleton_data_res
var view_index = 0
var has_spine = false

var selected_category: CategoryData
var selected_character: CharacterData
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_category_btns()
	create_character_btns()
	create_cg_btns()
	reset()
	#play_start_anim()
	#await tween.finished

func reset():
	cg_view_root.visible = false
	cg_btns_view.visible = false
	cg_view_btn.visible = false
	cg_spine.visible = false
	full_view.visible = false
	full_view_spine.visible = false
	_on_category_btn_pressed(0) # 開第一個


func play_start_anim():
	tween = create_tween()
	tween.tween_property(phone, "position", phone.position, 1)
	phone.position.y += phone.size.y
	

func show_cg_btns():
	cg_view_root.visible = true
	cg_btns_view.visible = true
	cg_view_btn.visible = false
	cg_spine.visible = false
	load_imgs()
	
	var data: CharacterData = selected_character
	for i in cg_btns.size():
		var btn: Button = cg_btns[i]
		if i <= data.level:
			btn.icon = review_imgs[i]
			btn.visible = true
		elif has_spine:
			btn.icon = play_icon
			btn.expand_icon = false
		else:
			btn.visible = false


func show_cg_view():
	cg_btns_view.visible = false
	if view_index < review_imgs.size():
		cg_spine.visible = false
		cg_view_btn.icon = review_imgs[view_index]
		cg_view_btn.visible = true
	else:
		cg_view_btn.visible = false
		cg_spine.skeleton_data_res = skeleton_data_res
		cg_spine.play_first_anim()
		cg_spine.visible = true


func show_full_view():
	full_view.visible = true
	full_view_img.texture = review_imgs[view_index]


func create_category_btns():
	var offset_y = 20
	for i in Main.categorys_data.size():
		var category_data: CategoryData = Main.categorys_data[i]
		var btn: Button = category_btn.instantiate()
		btn.text = tr(category_data.category) + " " + category_data.get_progress_str()
		btn.position = Vector2(
			0,
			offset_y + i * (btn.size.y + offset_y)
		)
		btn.pressed.connect(_on_category_btn_pressed.bind(i))
		categorys_view.add_child(btn)
		category_list_btns.append(btn)


func create_character_btns():
	var character_count = 5
	for i in character_count:
		var btn: Button = character_btn.instantiate()
		btn.pressed.connect(_on_character_button_pressed.bind(i))
		btn.position = Vector2(
			phone.position.x + phone.size.x + 20,
			((size.y - btn.size.y * character_count)/(character_count+1) + btn.size.y) * i
		)
		characters_view.add_child(btn)
		character_btns.append(btn)


func create_cg_btns():
	var count = 4
	var offset = 30
	for i in count:
		var btn = ButtonEx.new()
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		btn.size = Vector2(
			(cg_view_root.size.x - offset * 3)/2.0,
			(cg_view_root.size.y - offset * 3)/2.0
		)
		btn.position = Vector2(
			offset + (offset + btn.size.x) * (i%2),
			offset + (offset + btn.size.y) * floor(i/2.0)
		)
		btn.pressed.connect(_on_cg_btn_pressed.bind(i))
		cg_btns_view.add_child(btn)
		cg_btns.append(btn)


func load_imgs():
	var data: CharacterData = selected_character
	review_imgs.clear()
	for i in data.level+1:
		review_imgs.append(load(data.get_cg_path(i)))
	if has_spine:
		skeleton_data_res = load(data.get_spine_path())


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
	reset()

func return_scene():
	if full_view.visible:
		full_view.visible = false
		cg_view_btn.visible = false
	else:
		Main.to_scene(Main.SCENE.start)


func _on_category_btn_pressed(index):
	Main.play_btn_sfx()
	for btn: Button in category_list_btns:
		btn.button_pressed = false
	category_list_btns[index].button_pressed = true
	selected_category = Main.categorys_data[index]
	refresh_characters()


func _on_character_button_pressed(extra_arg_0: int) -> void:
	selected_character = selected_category.characters[extra_arg_0]
	#show_review(selected_character)
	has_spine = selected_character.has_bonus and selected_character.get_spine_path() != ""
	show_cg_btns()


func _on_cg_btn_pressed(index: int):
	view_index = index
	show_cg_view()


func _on_return_button_pressed() -> void:
	return_scene()


func _on_cg_view_pressed() -> void:
	show_full_view()


func _on_view_button_pressed() -> void:
	view_index += 1
	if view_index < review_imgs.size():
		full_view_img.texture = review_imgs[view_index]
	elif view_index == review_imgs.size() and has_spine:
		# 顯示spine
		full_view_img.visible = false
		full_view_spine.skeleton_data_res = skeleton_data_res
		full_view_spine.play_first_anim()
		full_view_spine.visible = true
	else:
		# 關閉
		full_view.visible = false
		# 初始化
		full_view_img.visible = true
		full_view_spine.visible = false
		view_index = 0
