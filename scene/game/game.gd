extends Control

var character_data: Main.CharacterData
var character_imgs = []
var menu_btn: MenuButton
# 對話
var story_view: Control
var story_character: TextureRect
var talk_view: TextureRect
var talk_lbl: Label
# 猜拳
var game_state = STATE.對話
var game_character: TextureRect
var now_level: int
var tip_view: TextureRect
var tip_lbl: Label
var player_choice_sp: Sprite2D
var bot_choice_sp: Sprite2D
var player_choice
var bot_choice
var choice_str = ["剪刀", "石頭", "布"]
var choice_img_path = "res://scene/game/%s.png"

enum STATE {
	退出 = -1,
	對話 = 0,
	猜拳 = 1,
	通關 = 2
}

enum CHOICES {
	剪刀,
	石頭,
	布
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	reset_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	character_data = Main.current_character_data
	story_view = $Story
	story_character = $Story/StoryCharacter
	talk_view = $Story/Talk
	talk_lbl = $Story/Talk/Label
	game_character = $Game/GameCharacter
	tip_view = $Game/TipView
	tip_lbl = $Game/TipView/TipLabel
	player_choice_sp = $"Game/我方出拳"
	bot_choice_sp = $"Game/對方出拳"
	menu_btn = $Game/MenuButton
	var popup: PopupMenu = menu_btn.get_popup()
	popup.add_theme_font_size_override("font_size", 50) # 改字體大小
	popup.id_pressed.connect(_on_popup_item_pressed)


func reset_game():
	load_imgs()
	game_state = STATE.對話
	story_view.visible = true
	# 已通關時重新開始
	if character_data.progress >= character_data.level:
		now_level = 0
	else:
		now_level = character_data.progress
	refresh_game()


func refresh_game():
	story_character.texture = character_imgs[now_level]
	game_character.texture = character_imgs[now_level]
	set_choice_visible(false)
	$"Game/進度".text = "進度 " + str(now_level) + "/" + str(character_data.level)
	talk_lbl.text = character_data.story[now_level]
	if now_level >= character_data.level:
		game_state = STATE.通關


func load_imgs():
	var file_name = character_data.file_name
	for i in character_data.story.size():
		var path = "res://characters/" + file_name + "/" + file_name + "_" + str(i+1) + ".jpg"
		var img = load(path)
		character_imgs.append(img)


func to_continue():
	match game_state:
		STATE.對話:
			if TransitionEffect.main != null:
				# 跳過轉場動畫
				TransitionEffect.skip_anim()
			#elif talk_view.visible == false:
				## 開啟對話
				#talk_view.visible = true
			elif story_view.visible == true:
				# 關閉對話
				story_view.visible = false
				# 開始猜拳
				game_state = STATE.猜拳
			elif story_view.visible == false:
				# 猜拳完進對話
				refresh_game()
				story_view.visible = true
		STATE.通關:
			quite()


# 顯示雙方猜拳
func show_choice():
	player_choice_sp.texture = load(choice_img_path % choice_str[player_choice])
	bot_choice_sp.texture = load(choice_img_path % choice_str[bot_choice])
	set_choice_visible(true)
	
func set_choice_visible(to_set: bool):
	player_choice_sp.visible = to_set
	bot_choice_sp.visible = to_set
	tip_view.visible = to_set


# 輸贏判定
func play_logic():
	bot_choice = randi_range(0, 2)
	show_choice()
	var result = determine_winner(player_choice, bot_choice)
	match result:
		0:
			tip_lbl.text = "平手"
		1:
			now_level += 1
			if character_data.progress < now_level:
				character_data.progress = now_level
			game_state = STATE.對話
			tip_lbl.text = "贏了"
		-1:
			tip_lbl.text = "輸了"

# 猜拳判定
func determine_winner(player, bot):
	if player == bot:
		return 0
	elif (player == CHOICES.石頭 and bot == CHOICES.剪刀) or (player == CHOICES.剪刀 and bot == CHOICES.布) or (player == CHOICES.布 and bot == CHOICES.石頭):
		return 1
	else:
		return -1


func show_scene():
	reset_game()


func quite():
	Main.to_scene(Main.SCENE.menu)
	game_state = STATE.退出


# 點擊猜拳
func _on_choice_btn_pressed(tag):
	player_choice = tag
	play_logic()


func _on_popup_item_pressed(id: int) -> void:
	match id:
		0:
			# 設定
			Main.show_setting_view()
		1:
			# 退出
			quite()


func _input(event):
	# 滑鼠任何鍵
	if event is InputEventMouseButton and event.pressed and game_state != STATE.退出:
		to_continue()
