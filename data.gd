extends Node

var game_scene = preload("res://game.tscn").instantiate()

var this_platform: String = "steam"
var steam_api: Object = null
var steam_id: int
var steam_name: String

func start_game():
	get_tree().root.add_child(game_scene)

# steam 初始化
func initialize_steam() -> void:
	this_platform = "other"
	steam_id = 0
	steam_name = "You"
	
	if Engine.has_singleton("Steam"):
		this_platform = "steam"
		steam_api = Engine.get_singleton("Steam")

		var initialized: Dictionary = steam_api.steamInitEx(false)

		print("[STEAM] 初始化?: %s" % initialized)

		if initialized['status'] > 0:
			print("Steam初始化失敗, 停用功能: %s" % initialized)
			steam_api = null
			return
		
		steam_id = steam_api.getSteamID()
		steam_name = steam_api.getPersonaName()

func is_steam_enabled() -> bool:
	if this_platform == "steam" and steam_api != null:
		return true
	return false
