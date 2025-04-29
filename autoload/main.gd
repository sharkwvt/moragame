extends Node

var screen_size = Vector2i(1920, 1080)

var categorys_path = "res://categorys"
var category_json_path = "res://categorys/%s/data.json"
var talk_json_path = "res://data/json/talk.json"
var game_save_path = "user://moragame.sav"
var csv_path = "res://categorys/%s/csv"

# 視窗
var setting_view = preload("res://common/setting/setting_view.tscn")
var talk_view = preload("res://common/talk/talk.tscn")
var dialog_view = preload("res://common/dialog/dialog.tscn")
# 場景
var category_scene = preload("res://scene/category/category.tscn")
var menu_scene = preload("res://scene/menu/menu.tscn")
var game_scene = preload("res://scene/game/game.tscn")
var review_scene = preload("res://scene/review/review.tscn")

var music_1 = preload("res://sound/maou_bgm_acoustic50.mp3")
var btn_sfx = preload("res://sound/maou_se_system47.mp3")

var mouse_click_effect = preload("res://common/mouse_click_effect.tscn")
var mouse_trail_effect: GPUParticles2D

var categorys_data = []
var characters_data = []
var talk_data: TalkData

var current_scene: Control
var current_character_data: CharacterData
var current_category_data: CategoryData

var instance_scenes = [0, 0, 0, 0, 0]
enum SCENE {
	start,
	category,
	menu,
	game,
	review
}


var music_player: AudioStreamPlayer

var this_platform: String = "other" # 遊戲平台

const STAT_KEY_Characters = "characters_data"
# 要同步的數據
var statistics: Dictionary = {
	STAT_KEY_Characters: []
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_data()
	Input.set_custom_mouse_cursor(load("res://image/mouse.png"),Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(load("res://image/mouse2.png"),Input.CURSOR_POINTING_HAND)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#move_mouse_trail()
	pass


func move_mouse_trail():
	if mouse_trail_effect == null:
		create_mouse_trail()
	mouse_trail_effect.position = get_tree().root.get_mouse_position()
	

func create_mouse_trail():
	mouse_trail_effect = GPUParticles2D.new()
	mouse_trail_effect.texture = load("res://image/spark_particle2.png")
	var ppm := ParticleProcessMaterial.new()
	ppm.gravity = Vector3.ZERO # 清除重力
	mouse_trail_effect.process_material = ppm
	mouse_trail_effect.amount = 10
	mouse_trail_effect.speed_scale = 2
	mouse_trail_effect.emitting = true
	get_tree().root.add_child(mouse_trail_effect)


func play_music(music):
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.bus = "Music"
		music_player.finished.connect(_on_music_finished)
		add_child(music_player)
	music_player.stream = music
	music_player.play()


func to_scene(scene: SCENE, anim_type = 0):
	if instance_scenes[scene] is Control:
		# 使用已創建的場景
		instance_scenes[scene].move_to_front()
		instance_scenes[scene].show_scene()
		# 避免閃爍
		await get_tree().process_frame
		instance_scenes[scene].visible = true
	else:
		# 創建場景
		match scene:
			SCENE.category:
				instance_scenes[scene] = category_scene.instantiate()
			SCENE.menu:
				instance_scenes[scene] = menu_scene.instantiate()
			SCENE.game:
				instance_scenes[scene] = game_scene.instantiate()
			SCENE.review:
				instance_scenes[scene] = review_scene.instantiate()
		get_tree().root.add_child(instance_scenes[scene])
		
	TransitionEffect.start_transition(current_scene, anim_type)
	current_scene = instance_scenes[scene]
	
	# 滑鼠特效移到最前
	#mouse_trail_effect.move_to_front()

func get_menu_scene() -> MenuScene:
	return instance_scenes[SCENE.menu]

func reload_data():
	load_categorys_data()
	load_talk_data()
	load_csv()
	load_game_save()

func load_categorys_data():
	categorys_data.clear()
	
	var dir = DirAccess.open(categorys_path)
	if dir == null:
		print("無法開啟資料夾: ", categorys_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			print("load_category_data: ", file_name)
			var category_data = CategoryData.new()
			category_data.category = file_name		
			category_data.path = categorys_path + "/" + file_name
			if FileAccess.file_exists(category_data.get_menu_path()):
				category_data.menu = load(category_data.get_menu_path())
			else:
				print(category_data.get_menu_path() + " 不存在")
			categorys_data.append(category_data)
			var json_data = get_json_data(category_json_path % file_name)
			if !json_data.is_empty():
				category_data.id = int(json_data["category"]["id"])
				category_data.category_title=json_data["category"]["title"]
				category_data.category_desc=json_data["category"]["desc"]
				var characters: Array = json_data["characters"]
				for character: Dictionary in characters:
					var data = CharacterData.new()
					for key in character.keys():
						if key in data:
							data.set(key, character[key])
					data.category = category_data.category
					characters_data.append(data)
					category_data.characters.append(data)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# 排序
	categorys_data.sort_custom(func(a, b): return a["id"] < b["id"])


func load_talk_data():
	var json_data = get_json_data(talk_json_path)
	if !json_data.is_empty():
		talk_data = TalkData.new()
		talk_data.lose_strs = json_data["lose"]
		talk_data.win_strs = json_data["win"]
		talk_data.pass_strs = json_data["pass"]


func save_game():
	statistics[STAT_KEY_Characters] = []
	var save_file = FileAccess.open(game_save_path, FileAccess.WRITE)
	
	for data: CharacterData in characters_data:
		var dic = {
			"id" = data.id,
			"progress" = data.progress,
			"has_bonus" = data.has_bonus
		}
		statistics[STAT_KEY_Characters].append(dic)
		
	#save_file.store_line(JSON.stringify(statistics))
	save_file.store_var(statistics)


func load_game_save():
	if not FileAccess.file_exists(game_save_path):
		print("存擋不存在")
		return
		
	var file := FileAccess.open(game_save_path, FileAccess.READ)
	if not file:
		print("讀取存擋失敗")
		return
		
	#var content := file.get_as_text()
	#file.close()
	#
	#var json = JSON.new()
	#var pares_result := json.parse(content)
	#if pares_result != OK:
		#print("存擋內容錯誤")
		#return
	
	#statistics = json.data
		
	var save_data = file.get_var()
	file.close()
	if save_data == null:
		print("存擋為空")
		return
		
	statistics = save_data
	for data: CharacterData in characters_data:
		for obj in statistics[STAT_KEY_Characters]:
			if obj["id"] == data.id:
				data.progress = obj["progress"]
				data.has_bonus = obj["has_bonus"]


func load_csv():
	for category: CategoryData in categorys_data:
		var path = csv_path % category.category
		var dir = DirAccess.open(path)
		if dir == null:
			print("無法開啟資料夾: ", path)
			continue
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if ".translation" in file_name:
				var file_path = path.path_join(file_name)
				print("load_csv: ", file_path)
				TranslationServer.add_translation(load(file_path))
			file_name = dir.get_next()
		dir.list_dir_end()


func get_json_data(path: String) -> Dictionary:
	var json = JSON.new()
	if not FileAccess.file_exists(path):
		print(path + " 不存在")
		return {}
		
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("讀取" + path + "失敗")
		return {}
		
	var content := file.get_as_text()
	file.close()
	
	var pares_result := json.parse(content)
	if pares_result != OK:
		print(path + "內容錯誤")
		return {}
	
	return json.data


func show_setting_view():
	get_tree().root.add_child(setting_view.instantiate())


func show_talk_view(text):
	var view = talk_view.instantiate()
	get_tree().root.add_child(view)
	view.show_talk_anim(text)
	view.tween.finished.connect(view.queue_free)


func play_sfx(sfx):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sfx
	audio_player.bus = "SFX"
	audio_player.finished.connect(audio_player.queue_free)
	get_tree().root.add_child(audio_player)
	audio_player.play()

func play_btn_sfx():
	play_sfx(btn_sfx)


func show_tip(msg: String):
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 50)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	lbl.text = msg
	lbl.position = get_viewport().get_mouse_position()
	get_tree().root.add_child(lbl)
	var tween: Tween = lbl.create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position:y", lbl.position.y - 100, 3)
	tween.tween_property(lbl, "modulate:a", 0, 3)
	#tween.finished.connect(lbl.queue_free)
	await tween.finished
	lbl.queue_free()
	tween.kill()


func show_dialog(msg: String):
	var dialog = ConfirmationDialog.new()
	current_scene.add_child(dialog)
	dialog.dialog_text = msg
	dialog.popup_centered()
	dialog.confirmed.connect(func(): print("okokok1"))
	dialog.canceled.connect(func(): print("okokok2"))


func create_dialog_view() -> DialogView:
	var dialog = dialog_view.instantiate()
	get_tree().root.add_child(dialog)
	return dialog


func _on_music_finished():
	music_player.play()


func _input(event):
	# 滑鼠任何鍵
	if event is InputEventMouseButton and event.pressed:
		var click_effect: GPUParticles2D = mouse_click_effect.instantiate()
		click_effect.emitting = true		
		click_effect.position = Vector2(event.position.x+0,event.position.y+0)
		get_tree().root.add_child(click_effect)
		
func _unhandled_key_input(event: InputEvent) -> void:
	#if event.is_action_pressed("scale_time"):
		#get_tree().paused = not get_tree().paused
	
	if event.is_action_pressed("ui_cancel"):
		if !TransitionEffect.main and current_scene.visible:
			current_scene.return_scene()
