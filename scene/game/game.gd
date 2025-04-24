extends Scene

@export var menu_btn: MenuButton
@export var character: TextureRect
@export var character_temp: TextureRect
@export var character_light_mask: TextureRect
@export var character_light: ColorRect
@export var progress_bar: TextureProgressBar
# 對話
@export var story_view: Control
@export var talk_view: TextureRect
# 猜拳
@export var choice_btn: PackedScene
@export var game_view: Control
@export var tips_node: Control
@export var result_spine: SpineSprite
@export var user_spine: SpineSprite
@export var npc_spine: SpineSprite
# bonus
@export var bonus_view: Control
@export var spine_sprite: SpineSpriteEx

var character_data: CharacterData
var character_imgs = []
var is_bonus = false
var game_state = STATE.對話
var character_tween: Tween
var has_dialog: bool
var dialog
# 猜拳
var now_level: int
var pb_tween: Tween
var game_tween: Tween
var player_choice_btns = []
var player_choice
var bot_choice
var choice_str = ["scissors", "rock", "paper"]

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
	var popup: PopupMenu = menu_btn.get_popup()
	popup.add_theme_font_size_override("font_size", 50) # 改字體大小
	popup.id_pressed.connect(_on_popup_item_pressed)
	
	var count = 3
	for i in count:
		var btn: Button = choice_btn.instantiate()
		var offset = btn.size.x + 100
		btn.position = Vector2(
			size.x/2.0 + (i - count/2.0) * offset,
			#size.y - btn.size.y + 100
			size.y - btn.size.y
		)
		btn.setup(i)
		player_choice_btns.append(btn)
		btn.pressed.connect(_on_choice_btn_pressed.bind(i))
		game_view.add_child(btn)


func reset_game():
	character_data = Main.current_character_data
	progress_bar.value = 0
	load_imgs()
	set_character_tween()
	game_state = STATE.對話
	bonus_view.visible = false
	tips_node.visible = false
	# 已通關時重新開始
	if character_data.progress >= character_data.level or is_bonus:
		now_level = 0
	else:
		now_level = character_data.progress
	character.texture = character_imgs[now_level]
	refresh_game()
	show_story()


func refresh_game():
	character.pivot_offset = Vector2(character.size.x/2.0, character.size.y/2.0)
	#$"Game/進度".text = "進度 " + str(now_level) + "/" + str(character_data.level)
	set_progress(float(now_level)/character_data.level)
	if now_level >= character_data.level:
		game_state = STATE.通關


func load_imgs():
	character_imgs.clear()
	for i in character_data.level+1:
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
				play_character_switch_anim()
				show_story()
			
		STATE.通關:
			Main.get_menu_scene().show_unlock_anim = true
			if is_bonus:
				character_data.has_bonus = true
				Main.save_game()
				show_bonus()
			else:
				quite()
			
		STATE.bonus:
			quite()


func set_progress(ps: float):
	if progress_bar.value == ps:
		return
	
	if pb_tween:
		pb_tween.kill()
	pb_tween = progress_bar.create_tween()
	pb_tween.set_trans(Tween.TRANS_QUART)
	pb_tween.set_ease(Tween.EASE_OUT)
	pb_tween.tween_property(progress_bar, "value", ps, 1)
	pb_tween.parallel().tween_property($progress, "scale", Vector2(1.05, 1.05), 1)
	pb_tween.tween_property($progress, "scale", Vector2(1, 1), 1)


func set_character_tween():
	character.scale = Vector2i(1, 1)
	if character_tween:
		character_tween.kill()
	character_tween = character.create_tween()
	character_tween.set_loops()
	character_tween.tween_property(character, "scale", Vector2(1.05, 1.05), 1)
	character_tween.tween_property(character, "scale", Vector2(1, 1), 1)


func play_character_switch_anim():
	if character_tween:
		character_tween.kill()
		
	var duration = 0.3
	
	character_temp.texture = character.texture
	var mt: ShaderMaterial = character_temp.material
	mt.set_shader_parameter("alpha", 1.0)
	character_light_mask.texture = character.texture
	character_light.color.a = 0
	character.texture = character_imgs[now_level]
	
	character_tween = character.create_tween()
	character_tween.tween_property(character, "scale", Vector2(1.1, 1.1), duration)
	character_tween.parallel().tween_property(mt, "shader_parameter/alpha", 0.0, duration)
	character_tween.parallel().tween_property(character_light, "color:a", 0.5, duration)
	character_tween.tween_property(character, "scale", Vector2(1, 1), duration)
	character_tween.parallel().tween_property(character_light, "color:a", 0, duration)
	await character_tween.finished
	set_character_tween()
	

func show_story():
	story_view.visible = true
	game_view.visible = false
	var talk_str = Main.talk_data.get_win_str()
	if now_level == 0:
		talk_str = Main.talk_data.get_lose_str()
	if now_level == character_data.level:
		talk_str = Main.talk_data.get_pass_str()
	talk_view.show_talk_anim(talk_str)
	# 播完動畫後繼續
	await talk_view.tween.finished
	to_continue()


func show_bonus():
	game_state = STATE.bonus
	story_view.visible = false
	game_view.visible = false
	bonus_view.visible = true
	spine_sprite.skeleton_data_res = load(character_data.get_spine_path())
	spine_sprite.play_first_anim()


# 顯示雙方猜拳
func switch_choice(is_show: bool):
	tips_node.visible = is_show
	for btn: Button in player_choice_btns:
		btn.disabled = is_show
		#btn.visible = not is_show
	
	if is_show:
		var user_skel: SpineSkeleton = user_spine.get_skeleton()
		user_skel.set_skin_by_name(choice_str[player_choice])
		var user_anim: SpineAnimationState = user_spine.get_animation_state()
		user_anim.set_animation("user_a", false)
		var npc_skel: SpineSkeleton = npc_spine.get_skeleton()
		npc_skel.set_skin_by_name(choice_str[bot_choice])
		var npc_anim: SpineAnimationState = npc_spine.get_animation_state()
		npc_anim.set_animation("npc_a", false)


func gameover():
	if has_dialog:
		close_dialog()
	has_dialog = true
	dialog = Main.create_dialog_view()
	dialog.title.text = "挑戰失敗"
	dialog.msg.text = "要再來一次嗎？"
	dialog.confirm_btn.text = "重試"
	dialog.cancel_btn.text = "返回"
	dialog.confirm_btn.pressed.connect(_on_again_button_pressed)
	dialog.cancel_btn.pressed.connect(_on_return_confirm)
	set_progress(0)


# 輸贏判定
func play_logic():
	bot_choice = randi_range(0, 2)
	var result = determine_winner(player_choice, bot_choice)
	var result_str: String
	match result:
		0:
			result_str = "DRAW"
		1:
			now_level += 1
			if character_data.progress < now_level:
				character_data.progress = now_level
				Main.save_game()
			game_state = STATE.對話
			result_str = "WIN"
		-1:
			result_str = "LOSE"
	
	# 輸贏動畫
	#await game_tween.finished
	switch_choice(true)
	var anim: SpineAnimationState = result_spine.get_animation_state()
	anim.set_animation(result_str, false)
	tips_node.visible = true
	
	await result_spine.animation_completed
	switch_choice(false)
	if result == -1:
		if is_bonus:
			gameover()
		talk_view.show_talk_anim(Main.talk_data.get_lose_str())
	else:
		to_continue()

# 猜拳判定
func determine_winner(player, bot):
	if player == bot:
		return 0
	elif (player == CHOICES.石頭 and bot == CHOICES.剪刀) or (player == CHOICES.剪刀 and bot == CHOICES.布) or (player == CHOICES.布 and bot == CHOICES.石頭):
		return 1
	else:
		return -1


func show_return_check():
	if has_dialog:
		return
	has_dialog = true
	dialog = Main.create_dialog_view()
	dialog.title.text = "提示"
	dialog.msg.text = "確定要退出嗎？"
	dialog.confirm_btn.pressed.connect(_on_return_confirm)
	dialog.cancel_btn.pressed.connect(_on_dialog_cancel)


func close_dialog():
	dialog.queue_free()
	has_dialog = false


func quite():
	Main.to_scene(Main.SCENE.menu)
	game_state = STATE.退出


func show_scene():
	reset_game()

func return_scene():
	show_return_check()


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


#func _input(event):
	## 滑鼠任何鍵
	#if event is InputEventMouseButton and event.pressed and game_state == STATE.bonus:
		#to_continue()


func _on_again_button_pressed() -> void:
	close_dialog()
	reset_game()

func _on_return_button_pressed() -> void:
	show_return_check()
	
func _on_return_confirm():
	close_dialog()
	quite()
	
func _on_dialog_cancel():
	close_dialog()
	
