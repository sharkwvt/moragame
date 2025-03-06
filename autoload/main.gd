extends Node

var setting_view = preload("res://setting_view.tscn")

var menu_scene = preload("res://scene/menu/menu.tscn")
var game_scene = preload("res://old/old_game.tscn")

var music_1 = preload("res://sound/maou_bgm_acoustic50.mp3")

var instance_scenes = [0, 0, 0]
enum SCENE {
	start,
	menu,
	game
	}

var music_player: AudioStreamPlayer

var this_platform: String = "other" # 遊戲平台

# 要同步的數據
var statistics: Dictionary = {
	"代幣": 0
	}
const STAT_KEY_COIN = "代幣"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

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


func to_scene(scene: SCENE):
	if instance_scenes[scene] is Node:
		instance_scenes[scene].show_scene()
	else:
		match scene:
			SCENE.menu:
				instance_scenes[scene] = menu_scene.instantiate()
			SCENE.game:
				instance_scenes[scene] = game_scene.instantiate()
		get_tree().root.add_child(instance_scenes[scene])


func show_setting_view():
	get_tree().root.add_child(setting_view.instantiate())


func _on_music_finished():
	music_player.play()
