extends Control

var character_data: Main.CharacterData
var character_imgs = []
var menu_btn: MenuButton
var is_bonus = false
var gameover_view: ColorRect
var game_state = STATE.對話
var game_character: TextureRect
var character_tween: Tween
# 對話
var story_view: Control
var talk_view: TextureRect
# 猜拳
var game_view: Control
var now_level: int
var tip_spine: SpineSprite
var spine_path = "res://scene/game/win_lose_draw/%s.tres"
var game_tween: Tween
var choice_btn = preload("res://scene/game/choice_btn/choice_btn.tscn")
var player_choice_btns = []
var bot_choice_btns = []
var player_choice
var bot_choice
var choice_str = ["剪刀", "石頭", "布"]
var choice_img_path = "res://scene/game/image/%s.png"
# bonus
var bonus_view: Control
var spine_sprite: SpineSprite

enum STATE {
	退出 = -1,
	對話 = 0,
	猜拳 = 1,
	通關 = 2,
	bonus = 3
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
	game_character = $Character
	story_view = $Story
	talk_view = $Story/Talk
	game_view = $Game
	tip_spine = $Game/Tip
	menu_btn = $Game/MenuButton
	bonus_view = $Bonus
	spine_sprite = $Bonus/SpineSprite
	gameover_view = $GameOver
	var popup: PopupMenu = menu_btn.get_popup()
	popup.add_theme_font_size_override("font_size", 50) # 改字體大小
	popup.id_pressed.connect(_on_popup_item_pressed)
	
	var count = 3
	for i in count:
		var btn: Button = choice_btn.instantiate()
		var offset = btn.size.x + 100
		btn.position = Vector2(
			size.x/2.0 + (i - count/2.0) * offset,
			size.y - btn.size.y + 100
		)
		btn.setup(i)
		player_choice_btns.append(btn)
		btn.pressed.connect(_on_choice_btn_pressed.bind(i))
		game_view.add_child(btn)
		
		var bot_btn: Button = choice_btn.instantiate()
		bot_btn.position = Vector2(
			size.x/2.0 + (i - count/2.0) * offset,
			-50
		)
		bot_btn.scale.y = -1
		bot_btn.setup(i, true)
		bot_choice_btns.append(bot_btn)
		game_view.add_child(bot_btn)


func reset_game():
	character_data = Main.current_character_data
	load_imgs()
	set_character_tween()
	game_state = STATE.對話
	bonus_view.visible = false
	gameover_view.visible = false
	tip_spine.visible = false
	# 已通關時重新開始
	if character_data.progress >= character_data.level or is_bonus:
		now_level = 0
	else:
		now_level = character_data.progress
	refresh_game()
	show_story()


func refresh_game():
	game_character.texture = character_imgs[now_level]
	game_character.pivot_offset = Vector2(game_character.size.x/2.0, game_character.size.y/2.0)
	$"Game/進度".text = "進度 " + str(now_level) + "/" + str(character_data.level)
	if now_level >= character_data.level:
		game_state = STATE.通關


func load_imgs():
	character_imgs.clear()
	for i in character_data.story.size():
		var path = character_data.get_cg_path(i)
		var img = load(path)
		character_imgs.append(img)


func to_continue():
	match game_state:
		STATE.對話:
			if TransitionEffect.main != null:
				# 跳過轉場動畫
				TransitionEffect.skip_anim()
			elif story_view.visible == true:
				# 關閉對話，開始猜拳
				story_view.visible = false
				game_view.visible = true
				game_state = STATE.猜拳
			elif story_view.visible == false:
				## 猜拳完進對話
				refresh_game()
				show_story()
			
		STATE.通關:
			if is_bonus:
				character_data.has_bonus = true
				Main.save_game()
				show_bonus()
			else:
				quite()
			
		STATE.bonus:
			quite()


func set_character_tween():
	game_character.scale = Vector2i(1, 1)
	if character_tween:
		character_tween.kill()
	character_tween = game_character.create_tween()
	character_tween.set_loops()
	character_tween.tween_property(game_character, "scale", Vector2(1.05, 1.05), 1)
	character_tween.tween_property(game_character, "scale", Vector2(1, 1), 1)


func show_story():
	story_view.visible = true
	game_view.visible = false
	talk_view.show_talk_anim(character_data.story[now_level])
	# 播完動畫後繼續
	await talk_view.tween.finished
	to_continue()


func show_bonus():
	game_state = STATE.bonus
	story_view.visible = false
	game_view.visible = false
	bonus_view.visible = true
	spine_sprite.skeleton_data_res = load(character_data.get_spine_path())
	var anim: SpineAnimationState = spine_sprite.get_animation_state()
	anim.add_animation("animation")


# 顯示雙方猜拳
func switch_choice(is_show: bool):
	for btn: Button in player_choice_btns:
		btn.disabled = true
		#btn.visible = false
	
	var btn: Button = player_choice_btns[player_choice]
	var bot_btn: Button = bot_choice_btns[bot_choice]
	if game_tween:
		game_tween.kill()
	game_tween = game_view.create_tween()
	if is_show:
		game_tween.tween_property(btn, "position:y", size.y - btn.size.y, 0.5)
		game_tween.parallel().tween_property(bot_btn, "position:y", bot_btn.size.y, 0.5)
		btn.hand_up()
		bot_btn.hand_up()
	else:
		game_tween.tween_property(btn, "position", btn.pos, 0.2)
		game_tween.parallel().tween_property(bot_btn, "position", bot_btn.pos, 0.2)
		btn.hand_down()
		bot_btn.hand_down()
		await game_tween.finished
		for b: Button in player_choice_btns:
			b.disabled = false
			#btn.visible = true


func gameover():
	gameover_view.visible = true


# 輸贏判定
func play_logic():
	bot_choice = randi_range(0, 2)
	switch_choice(true)
	var result = determine_winner(player_choice, bot_choice)
	var result_str: String
	match result:
		0:
			result_str = "draw"
		1:
			now_level += 1
			if character_data.progress < now_level:
				character_data.progress = now_level
				Main.save_game()
			game_state = STATE.對話
			result_str = "win"
		-1:
			result_str = "lose"
	
	# 輸贏動畫
	await game_tween.finished
	tip_spine.skeleton_data_res = load(spine_path % result_str)
	var anim: SpineAnimationState = tip_spine.get_animation_state()
	anim.set_animation(result_str, false)
	tip_spine.visible = true
	
	await tip_spine.animation_completed
	switch_choice(false)
	to_continue()
	if is_bonus and result == -1:
		gameover()

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
		#to_continue()
		pass


func _on_again_button_pressed() -> void:
	reset_game()

func _on_return_button_pressed() -> void:
	quite()
