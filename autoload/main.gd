extends Node

var characters_json_path = "res://characters/characters.json"

var setting_view = preload("res://setting_view.tscn")

var menu_scene = preload("res://scene/menu/menu.tscn")
var game_scene = preload("res://scene/game/game.tscn")

var music_1 = preload("res://sound/maou_bgm_acoustic50.mp3")
var btn_sfx = preload("res://sound/maou_se_system47.mp3")

var current_scene: Control

var instance_scenes = [0, 0, 0]
enum SCENE {
	start,
	menu,
	game
}

class CharacterData:
	var id = 0
	var display_name: String
	var file_name: String
	var category: String
	var level: int
	var story: Array
	var progress = 0
var characters_json: Dictionary
var characters_data = []
var current_character_data: CharacterData

var music_player: AudioStreamPlayer

var this_platform: String = "other" # 遊戲平台

# 要同步的數據
var statistics: Dictionary = {
	"代幣": 0
	}
const STAT_KEY_COIN = "代幣"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_characters_data()

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
		instance_scenes[scene].visible = true
		instance_scenes[scene].move_to_front()
		instance_scenes[scene].show_scene()
	else:
		match scene:
			SCENE.menu:
				instance_scenes[scene] = menu_scene.instantiate()
			SCENE.game:
				instance_scenes[scene] = game_scene.instantiate()
		get_tree().root.add_child(instance_scenes[scene])
		
	TransitionEffect.start_transition(current_scene, anim_type)
	current_scene = instance_scenes[scene]


func load_characters_data():
	load_characters_json()
	if characters_json:
		var characters: Array = characters_json["characters"]
		for character: Dictionary in characters:
			var data = Main.CharacterData.new()
			for key in character.keys():
				if key in data:
					data.set(key, character[key])
			characters_data.append(data)


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
