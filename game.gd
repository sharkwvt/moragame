extends Node

@export var level_btn_scene: PackedScene
var now_level = 1
var level_count = 5
var win_coin = 20
var item_cost = [100, 200]
var now_coin = 0
var player_choice_sp
var bot_choice_sp
var wins_count
var player_choice
var bot_choice
var used_item: int # 0 不使用道具, 1 50%, 2 100%
var choice_str = ["剪刀", "石頭", "布"]
var choice_img_path = "res://Image/%s.png"

enum CHOICES {
	剪刀,
	石頭,
	布
	}

enum ITEM {
	無,
	道具1,
	道具2
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_choice_sp = $"Game/我方出拳"
	bot_choice_sp = $"Game/對方出拳"
	create_level_btns()
	reset_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func refresh_text():
	$"Game/勝場數".text = "勝場 " + str(wins_count) + "/" + str(now_level)
	$"Game/關卡數".text = "關卡 " + str(now_level)
	$"Game/代幣數".text = str(now_coin) + "代幣"

# 初始化遊戲
func reset_game():
	wins_count = 0
	refresh_text()

# 顯示雙方猜拳
func show_choice():
	#player_choice_sp = Sprite2D.new()
	player_choice_sp.texture = load(choice_img_path % choice_str[player_choice])
	#player_choice_sp.position = Vector2($Game.size.x/2.0, $Game.size.y/2.0)
	#$Game.add_child(player_choice_sp)
	
	#bot_choice_sp = Sprite2D.new()
	bot_choice_sp.texture = load(choice_img_path % choice_str[bot_choice])
	#bot_choice_sp.position = Vector2($Game.size.x/2.0, bot_choice_sp.texture.get_size().y)
	#bot_choice_sp.rotation_degrees = 180
	#$Game.add_child(bot_choice_sp)
	
	set_choice_visible(true)
	
	# 數秒後刪除
	#await get_tree().create_timer(3.0).timeout
	#player_choice_sp.queue_free()
	#bot_choice_sp.queue_free()

func set_choice_visible(visible):
	player_choice_sp.visible = visible
	bot_choice_sp.visible = visible

func play_logic():
	bot_choice = randi_range(0, 2)
	var result # 0 平手 1 贏 -1 輸
	match used_item:
		1: # 道具1
			now_coin -= item_cost[used_item - 1]
			if randf() > 0.5:
				bot_choice = get_losing_choice(player_choice)
		2: # 道具2
			now_coin -= item_cost[used_item - 1]
			bot_choice = get_losing_choice(player_choice)
	
	used_item = 0
	show_choice()
	
	result = determine_winner(player_choice, bot_choice)
	
	match result:
		0:
			show_msg("平手")
		1:
			show_msg("贏了")
			now_coin += win_coin
			wins_count += 1
		-1:
			show_msg("輸了")
			wins_count = 0
	
	if wins_count >= now_level:
		reset_game()
		show_msg("過關")
	
	refresh_text()

# 猜拳判定
func determine_winner(player, bot):
	if player == bot:
		return 0
	elif (player == CHOICES.石頭 and bot == CHOICES.剪刀) or (player == CHOICES.剪刀 and bot == CHOICES.布) or (player == CHOICES.布 and bot == CHOICES.石頭):
		return 1
	else:
		return -1

func get_losing_choice(choice):
	match choice:
		CHOICES.石頭: return CHOICES.剪刀
		CHOICES.布: return CHOICES.石頭
		CHOICES.剪刀: return CHOICES.布
	return CHOICES.石頭

# 創建關卡按鈕
func create_level_btns():
	var offset = 20 # 間隔
	for i in level_count:
		var btn = level_btn_scene.instantiate()
		# 計算橫向數量，以第一個為主
		var h_count = floor($Level.size.x / (btn.size.x + offset))
		btn.text = "關卡 "+ str(i+1)
		btn.add_theme_font_size_override("font_size", 50)
		btn.position = Vector2(
			($Level.size.x - btn.size.x)/2.0 + (i%int(h_count) - (h_count-1)/2.0) * (btn.size.x + offset),
			offset + floor(i/h_count) * (btn.size.y + offset)
		)
		# 綁定點擊事件
		btn.connect("pressed", Callable(self, "_on_level_btn_pressed").bind(i+1))
		btn.focus_mode = Control.FOCUS_NONE
		$Level.add_child(btn)

func refresh_btn():
	$"Game/按鈕/勝率50".button_pressed = used_item == ITEM.道具1
	$"Game/按鈕/勝率100".button_pressed = used_item == ITEM.道具2

func show_msg(msg):
	$Game/Title.text = msg

# 點擊猜拳與道具按鈕
func _on_choice_btn_pressed(tag):
	player_choice = tag
	play_logic()
	refresh_btn()

# 點擊道具按鈕
func _on_item_btn_pressed(tag):
	match tag:
		ITEM.道具1:
			if now_coin < item_cost[0]:
				show_msg("代幣不夠")
			elif used_item == tag:
				show_msg("取消道具")
				used_item = 0
			else:
				show_msg("使用道具1")
				used_item = 1
		ITEM.道具2:
			if now_coin < item_cost[1]:
				show_msg("代幣不夠")
			elif used_item == tag:
				show_msg("取消道具")
				used_item = 0
			else:
				show_msg("使用道具2")
				used_item = 2
	refresh_btn()

func _on_level_btn_pressed(level):
	now_level = level
	set_choice_visible(false)
	show_msg("關卡 " + str(level))
	reset_game()
