extends Node

var steam_appid: int = 3668520
#var steam_appid: int = 480 # 測試用
var steam_id: int = 0
var steam_name: String = "You"

var achievements: Dictionary = {
	"成就ID1": false,
	"成就ID2": false,
	"成就ID3": false
}

var dlc_data: Array

func _init() -> void:
	# 設定環境變數
	OS.set_environment("SteamAppId", str(steam_appid))
	OS.set_environment("SteamGameId", str(steam_appid))
	
	initialize_steam()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Steam.run_callbacks()


func is_steam_enabled() -> bool:
	if Main.this_platform == "steam":
		return true
	return false


# steam 初始化
func initialize_steam() -> void:
	if Engine.has_singleton("Steam"):
		var initialized: Dictionary = Steam.steamInitEx(true, steam_appid)
		
		print("[STEAM] 初始化: %s" % initialized)
		
		if initialized['status'] != Steam.STEAM_API_INIT_RESULT_OK:
			print("Steam初始化失敗, 停用功能: %s" % initialized)
			return
		
		Main.this_platform = "steam"
		steam_id = Steam.getSteamID()
		steam_name = Steam.getPersonaName()
		print("steam_id " + str(steam_id))
		print("steam_name " + steam_name)
		dlc_data = Steam.getDLCData()
		print(dlc_data)
		
		connect_steam_callbacks()


func connect_steam_callbacks() -> void:
	Steam.current_stats_received.connect(_on_steam_stats_ready)
	Steam.user_stats_received.connect(_on_steam_stats_ready)


func _on_steam_stats_ready(this_game: int, this_result: int, this_user: int) -> void:
	print("開始接收Steam數據和成就: %s / %s / %s" % [this_user, this_result, this_game])
	if this_user != steam_id:
		print("玩家不符, 本地:%s Steam:%s" % [steam_id, this_user])
		return
	if this_game != steam_appid:
		print("App ID 不符, 本地:%s Steam:%s" % [steam_appid, this_game])
		return
	if this_result != Steam.RESULT_OK:
		print("Steam數據和成就接收失敗:%s" % this_result)
		return
	load_steam_stats()
	load_steam_achievements()


# 讀取數據
func load_steam_stats() -> void:
	var statistics := Main.statistics
	for this_stat in statistics.keys():
		var steam_stat: int = Steam.getStatInt(this_stat)
		if statistics[this_stat] != steam_stat:
			print("數據 %s 數值不同, 取最大, 本地:%s Steam:%s" % [this_stat, statistics[this_stat], steam_stat])
			set_statistic(this_stat, statistics[this_stat] if statistics[this_stat] > steam_stat else steam_stat)
		else:
			print("數據 %s 數值相同" % this_stat)
	print("Steam數據讀取完成")


# 讀取成就
func load_steam_achievements() -> void:
	for this_achievement in achievements.keys():
		var steam_achievement: Dictionary = Steam.getAchievement(this_achievement)
		
		if not steam_achievement['ret']:
			print("Steam不存在 %s 成就" % this_achievement)
			break
		if achievements[this_achievement] == steam_achievement['achieved']:
			print("成就 %s 狀態相同, 不需更改" % this_achievement)
			break
		
		set_achievement(this_achievement)
	
	print("Steam成就讀取完成")


# 設定數據
func set_statistic(this_stat: String, new_value: int = 0) -> void:
	var statistics := Main.statistics
	if not statistics.has(this_stat):
		print("數據 %s 不存在" % this_stat)
		return
	
	statistics[this_stat] = new_value
	
	if not Steam.setStatInt(this_stat, new_value):
		print("數據 %s 設定成 %s 失敗" % [this_stat, new_value])
		return
		
	print("數據 %s 設定 %s 成功" % [this_stat, new_value])
	
	if not Steam.storeStats():
		print("數據觸發失敗")
		return
	
	print("數據傳送完成")


# 設定成就
func set_achievement(this_achievement: String) -> void:
	if not achievements.has(this_achievement):
		print("成就不存在: %s" % this_achievement)
		return
	
	achievements[this_achievement] = true
	
	if not Steam.setAchievement(this_achievement):
		print("成就設定失敗: %s" % this_achievement)
		return
	
	print("設定成就: %s" % this_achievement)
	
	if not Steam.storeStats():
		print("觸發成就失敗")
		return
	
	print("成就設定完成")


func show_DLC():
	if is_steam_enabled():
		Steam.activateGameOverlayToStore(1983901)
	else:
		Main.show_tip("需購買DLC")
