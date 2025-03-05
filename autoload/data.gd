extends Node

var game_scene = preload("res://game.tscn").instantiate()

var this_platform: String = "other" # 遊戲平台

# 要同步至Steam的數據
var statistics: Dictionary = {
	"代幣": 0
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_game():
	get_tree().root.add_child(game_scene)
