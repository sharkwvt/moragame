extends Scene
class_name CategoryScene

@export var info_view: TextureRect
@export var info_lbl: Label
@export var info_desc: Label
@export var info_timer: Timer
@export var info_avatar_root: ColorRect
@export var info_dlc_mark: TextureRect
@export var category_btn: PackedScene

var avatar_path = "res://scene/category/info/avatar/"

var btns = []
var info_char_index = 0
var info_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_character_btns()
	create_info_avatar()
	refresh()
	$CPUParticles2D.move_to_front()
	info_view.move_to_front()
	info_timer.timeout.connect(_on_timer_timeout)
	$SpineBG/SpineSprite.play_first_anim()
	Main.show_talk_view("挑一個好地點出擊，獲取勝利吧！")
	
	Steamworks.set_achievement(Steamworks.ACHV_Start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func create_character_btns():
	var categorys = Main.categorys_data
	var all_width = 0
	for i in categorys.size():
		var data: CategoryData = categorys[i]
		var btn: CategoryBtn = category_btn.instantiate()
		btn.texture_n = load(data.get_img_path(0))
		btn.texture_light = load(data.get_img_path(1))
		btn.texture_halo = load(data.get_img_path(2))
		btn.icon = btn.texture_n
		btn.position = Vector2.ZERO # 不知為何這樣才能取到size
		all_width += btn.size.x
		# 綁定點擊事件
		btn.pressed.connect(_on_category_btn_pressed.bind(data))
		btn.show_info.connect(show_info_view.bind(btn))
		btn.hide_info.connect(func(): info_view.visible = false)
		btns.append(btn)
		add_child(btn)
		
	# 排列
	var spaceing = (size.x - all_width) / (btns.size() + 1)
	var offset = spaceing
	for i in btns.size():
		var btn: Button = btns[i]
		btn.position = Vector2(
			offset,
			size.y * 0.8 - btn.size.y
		)
		offset += btn.size.x + spaceing

func create_info_avatar():
	var count = 5
	var offset = 75
	for i in count:
		var img_view = TextureRect.new()
		img_view.grow_horizontal = Control.GROW_DIRECTION_BOTH
		img_view.grow_vertical = Control.GROW_DIRECTION_BOTH
		img_view.position = Vector2(
			offset * (i - (count-1)/2.0),
			0
		)
		info_avatar_root.add_child(img_view)


func show_info_view(btn: CategoryBtn):
	info_view.visible = true
	
	# 資訊文字
	info_lbl.text = tr(btn.c_data.category_title) + " (" + btn.c_data.get_progress_str() + ")"
	info_desc.text = btn.c_data.category_desc
	info_lbl.visible_characters = 0
	info_desc.visible_characters = 0
	
	#if btn.is_lock:
		#info_timer.stop()
		#info_lbl.text = "未開放"
		#info_lbl.visible_characters = -1
	#else :
		#info_char_index = 0
		#info_timer.wait_time = 0.1
		#info_timer.start()
	info_char_index = 0
	info_timer.wait_time = 0.1
	info_timer.start()
	
	
	# 資訊位置
	var spacing = 0
	info_view.position.y = btn.position.y + btn.size.y - info_view.size.y - 15
	info_view.position.x = btn.position.x + btn.size.x + spacing
	if size.x - info_view.position.x < info_view.size.x:
		info_view.position.x = btn.position.x - spacing - info_view.size.x
	
	# 資訊動畫
	#if info_tween:
		#info_tween.kill()
	#info_view.modulate.a = 0
	#var duration = 1.0
	#info_tween = info_view.create_tween()
	#info_tween.tween_property(info_view, "modulate:a", 1.0, duration)
	
	info_dlc_mark.visible = !btn.c_data.has_dlc
	
	refresh_info_avatar(btn.c_data)

func refresh_info_avatar(dara: CategoryData):
	for i in info_avatar_root.get_children().size():
		var c_data: CharacterData = dara.characters[i]
		var img_view: TextureRect = info_avatar_root.get_children()[i]
		if c_data.get_avatar() != "":
			var path = avatar_path + "sex_girl_" + c_data.file_name + ".png"
			img_view.texture = load(path)
		else:
			img_view.texture = Texture.new()


func refresh():
	info_view.visible = false
	var categorys = Main.categorys_data
	for i in categorys.size():
		var btn = btns[i]
		var data = categorys[i]
		btn.set_data(data)
		if i > 0:
			#var temp: CategoryData = categorys[i-1]
			#btn.is_lock = temp.progress != temp.all_level or data.all_level == 0
			#btn.disabled = btn.is_lock
			btn.is_lock = !data.has_dlc
		btn.refresh_light_progress()


func show_scene():
	refresh()
	Main.show_talk_view("挑一個好地點出擊，獲取勝利吧！")

func return_scene():
	Main.to_scene(Main.SCENE.start)


func _on_category_btn_pressed(data: CategoryData):
	if data.has_dlc:
		Main.current_category_data = data
		Main.to_scene(Main.SCENE.menu, 2)
	else:
		Steamworks.show_DLC_store(data.dlc_id)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	return_scene()


func _on_timer_timeout() -> void:
	var count = tr(info_lbl.text).length()
	var countDesc = tr(info_desc.text).length()
	info_timer.wait_time = 0.3 / count
	if info_char_index < countDesc:
		info_char_index += 1
		info_lbl.visible_characters = info_char_index
		info_desc.visible_characters = info_char_index
		info_timer.start()
	else:
		info_timer.stop()
