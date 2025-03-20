extends Node

var characters_json_path = "res://characters/characters.json"
var game_save_path = "user://moragame.save"

var setting_view = preload("res://setting_view.tscn")

var category_scene = preload("res://scene/category/category.tscn")
var menu_scene = preload("res://scene/menu/menu.tscn")
var game_scene = preload("res://scene/game/game.tscn")
var review_scene = preload("res://scene/review/review.tscn")

var music_1 = preload("res://sound/maou_bgm_acoustic50.mp3")
var btn_sfx = preload("res://sound/maou_se_system47.mp3")

var current_scene: Control

var instance_scenes = [0, 0, 0, 0, 0]
enum SCENE {
	start,
	category,
	menu,
	game,
	review
}

class CharacterData:
	var id = 0
	var display_name: String
	var file_name: String
	var category: String
	var level: int
	var story: Array
	var progress = 0
	var has_bonus = false
	func get_avatar_path() -> String:
		return "res://characters/" + file_name + "/" + file_name + "_1.jpg"
	func get_cg_path(index) -> String:
		return "res://characters/" + file_name + "/" + file_name + "_" + str(index+1) + ".jpg"
var characters_json: Dictionary
var characters_data = []
var current_character_data: CharacterData

class CategoryData:
	var category: String
	var characters = []
	func get_progress_str() -> String:
		var all_level = 0
		var progress: float = 0
		for c_data in characters:
			all_level += c_data.level
			progress += c_data.progress
		return str(int(progress / all_level * 100)) + "%"
		
var categorys_data = []
var current_category_data: CategoryData

var music_player: AudioStreamPlayer

var this_platform: String = "other" # 遊戲平台

# 要同步的數據
var statistics: Dictionary = {
	"characters_data": []
}
const STAT_KEY_Characters = "characters_data"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
		instance_scenes[scene].visible = true
		instance_scenes[scene].move_to_front()
		instance_scenes[scene].show_scene()
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


func reload_data():
	load_characters_json()
	load_characters_data()
	create_test_data() # 測試用資料
	load_category_data()
	load_game_save()


func load_characters_data():
	characters_data.clear()
	if characters_json:
		var characters: Array = characters_json["characters"]
		for character: Dictionary in characters:
			var data = Main.CharacterData.new()
			for key in character.keys():
				if key in data:
					data.set(key, character[key])
			characters_data.append(data)

func create_test_data():
	for i in 16:
		var test_category = "category" + str(i % 3)
		var data = CharacterData.new()
		data.id = 99 + i
		data.category = test_category
		data.display_name = "who"+str(i)
		data.file_name = "test"
		data.level = 2
		data.story = ["test1", "test2", "test3"]
		characters_data.append(data)


func load_category_data():
	categorys_data.clear()
	if characters_data.size() > 0:
		for character: CharacterData in characters_data:
			var category_data: CategoryData
			var category = character.category
			for c_data: CategoryData in categorys_data:
				if c_data.category == category:
					category_data = c_data
					break
			if category_data == null:
				category_data = CategoryData.new()
				category_data.category = category
				categorys_data.append(category_data)
			category_data.characters.append(character)


func load_characters_json():
	if not FileAccess.file_exists(characters_json_path):
		print("characters.json不存在")
		return
		
	var file := FileAccess.open(characters_json_path, FileAccess.READ)
	if not file:
		print("讀取characters.json失敗")
		return
		
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var pares_result := json.parse(content)
	if pares_result != OK:
		print("characters.json內容錯誤")
		return
	
	characters_json = json.data


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
		
	save_file.store_line(JSON.stringify(statistics))


func load_game_save():
	if not FileAccess.file_exists(game_save_path):
		print("存擋不存在")
		return
		
	var file := FileAccess.open(game_save_path, FileAccess.READ)
	if not file:
		print("讀取存擋失敗")
		return
		
	var content := file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var pares_result := json.parse(content)
	if pares_result != OK:
		print("存擋內容錯誤")
		return
	
	statistics = json.data
	for data: CharacterData in characters_data:
		for obj in statistics[STAT_KEY_Characters]:
			if obj["id"] == data.id:
				data.progress = obj["progress"]
				data.has_bonus = obj["has_bonus"]


func show_setting_view():
	get_tree().root.add_child(setting_view.instantiate())


func play_sfx(sfx):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sfx
	audio_player.bus = "SFX"
	audio_player.finished.connect(audio_player.queue_free)
	get_tree().root.add_child(audio_player)
	audio_player.play()

func play_btn_sfx():
	play_sfx(btn_sfx)


func _on_music_finished():
	music_player.play()
