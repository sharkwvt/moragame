extends Scene
class_name CategoryScene

@export var info_view: NinePatchRect
@export var info_lbl: Label
@export var info_desc: Label
@export var info_timer: Timer

var category_btn = preload("res://scene/category/category_btn/category_btn.tscn")

var btns = []
var info_char_index = 0
var info_tween: Tween
# 資訊文字
var txt_title:String
var txt_desc:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	create_character_btns()
	refresh()
	$CPUParticles2D.move_to_front()
	info_view.move_to_front()
	info_timer.timeout.connect(_on_timer_timeout)
	$SpineBG/SpineSprite.play_first_anim()
	Main.show_talk_view("挑一個好地點出擊，獲取勝利吧！")


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
			size.y * 0.75 - btn.size.y
		)
		offset += btn.size.x + spaceing


func show_info_view(btn: CategoryBtn):
	info_view.visible = true
	
	txt_title = btn.c_data.category_title
	txt_desc = btn.c_data.category_desc
	info_lbl.text = txt_title
	info_lbl.visible_characters = 0
	info_desc.text = txt_desc
	info_desc.visible_characters = 0
	
	if btn.is_lock:				
		info_timer.stop()
		info_lbl.text = "未開放"
		info_lbl.visible_characters = -1
	else :
		info_char_index = 0
		info_timer.wait_time = 0.1
		info_timer.start()	
		
	
	
	# 資訊位置
	var spacing = 0
	info_view.position.y = btn.position.y + btn.size.y - info_view.size.y
	info_view.position.x = btn.position.x + btn.size.x + spacing
	if btn.position.x > size.x/2.0:
		info_view.position.x = btn.position.x - spacing - info_view.size.x
	
	# 資訊動畫
	#if info_tween:
		#info_tween.kill()
	#info_view.modulate.a = 0
	#var duration = 1.0
	#info_tween = info_view.create_tween()
	#info_tween.tween_property(info_view, "modulate:a", 1.0, duration)


func refresh():
	info_view.visible = false
	var categorys = Main.categorys_data
	for i in categorys.size():
		var btn = btns[i]
		var data = categorys[i]
		btn.set_data(data)
		if i > 0:
			var temp: CategoryData = categorys[i-1]
			btn.is_lock = temp.progress != temp.all_level or data.all_level == 0
			btn.disabled = btn.is_lock


func show_scene():
	refresh()
	Main.show_talk_view("挑一個好地點出擊，獲取勝利吧！")

func return_scene():
	Main.to_scene(Main.SCENE.start)


func _on_category_btn_pressed(data):
	Main.current_category_data = data
	Main.to_scene(Main.SCENE.menu, 2)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	return_scene()


func _on_timer_timeout() -> void:
	var count = info_lbl.text.length()
	var countDesc = info_desc.text.length()
	info_timer.wait_time = 0.3 / count
	if info_char_index < countDesc:
		info_char_index += 1
		info_lbl.visible_characters = info_char_index
		info_desc.visible_characters = info_char_index
		info_timer.start()
	else:
		info_timer.stop()
