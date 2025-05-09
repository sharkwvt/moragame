extends Control

var select_rooms = []
var category_data: CategoryData
var btns = []
var light_tween:Tween

var show_unlock_anim: bool
var is_to_bonus: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	$lightMask.mouse_filter = MOUSE_FILTER_IGNORE
	$SpineBG/SpineSprite.play_first_anim()
	Main.show_talk_view("今天，要攻略哪一個對象呢❤️")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	for i in range(1, 6):
		select_rooms.append(get_node("SelectRooms/SelectRoom" + str(i)))
		btns.append(get_node("MenuBtn" + str(i)))
	
	for i in btns.size():
		var btn: MenuBtn = btns[i]
		btn.index = i
		btn.mouse_entered.connect(_on_btn_mouse_entered.bind(i))
		btn.mouse_exited.connect(_on_btn_mouse_exited.bind(i))
		btn.pressed.connect(_on_btn_pressed.bind(i))
		btn.avatar_btn.pressed.connect(_on_btn_avatar_pressed.bind(i))
	
	refresh()


func set_btns():
	for i in btns.size():
		var btn: MenuBtn = btns[i]
		# 沒人了
		if i > category_data.characters.size()-1:
			btn.lock()
			continue
		var c_data: CharacterData = category_data.characters[i]
		btn.set_data(category_data, c_data)
		#if i > 0 and !btns[i-1].can_bonus:
			#btn.lock()
		#else:
			#if show_unlock_anim and c_data.progress == 0:
				#btn.play_unlock_anim()
			#else:
				#btn.open()
		btn.open()


func play_enter_effect(i):
	# 關閉鼠標感應
	for btn: MenuBtn in btns:
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tex: TextureRect = select_rooms[i] 
	tex.modulate.a = 0.6
	var tween = create_tween()
	tween.tween_property(
		tex,"modulate:a",2,0.3
	)
	tween.tween_property(
		$lightMask,"color:a",1,0.6
	)
	tween.finished.connect(start_game)

func start_game():
	Main.to_scene(Main.SCENE.game)
	Main.instance_scenes[Main.SCENE.game].is_bonus = is_to_bonus


func refresh():
	category_data = Main.current_category_data
	$lightMask.color.a= 0
	
	for tex: TextureRect in select_rooms:
		tex.modulate.a = 0
		
	# 開啟鼠標感應
	for btn: MenuBtn in btns:
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	set_btns()


func show_scene():
	refresh()
	if !show_unlock_anim:
		Main.show_talk_view("今天，要攻略哪一個對象呢❤️")

func return_scene():
	Main.to_scene(Main.SCENE.category)


func _on_btn_mouse_entered(id) -> void:
	var btn: MenuBtn = btns[id]
	if not btn.is_open:
		return
	var tex: TextureRect = select_rooms[id]
	tex.modulate.a = 0
	light_tween = create_tween()
	light_tween.tween_property(
		tex, "modulate:a", 0.6, 0.15
	)

func _on_btn_mouse_exited(id) -> void:
	var tex: TextureRect = select_rooms[id] 
	tex.modulate.a = 0
	if light_tween != null:
		light_tween.kill()

func _on_btn_pressed(i) -> void:
	var btn: MenuBtn = btns[i]
	if not btn.is_open:
		Main.show_tip("鎖住了")
		return
	Main.current_character_data = btn.character_data
	is_to_bonus = btn.to_bonus
	play_enter_effect(i)

func _on_btn_avatar_pressed(i):
	var btn: MenuBtn = btns[i]
	btn.on_click_avatar()

func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	return_scene()
