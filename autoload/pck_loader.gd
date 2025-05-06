extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pck_path = "res://pck_test.pck"
	var success = ProjectSettings.load_resource_pack(pck_path, false)
	if success:
		print(pck_path + " 讀取成功")


func load_dlc_pck(dlc_id: int):
	var file_dir = OS.get_executable_path().get_base_dir()
	
	var pck_name: String
	match dlc_id:
		123:
			pck_name = "dlc.pck"
		_:
			pck_name = "dlc.pck"
	var pck_path = file_dir.path_join("dlcs").path_join(pck_name)
	
	if FileAccess.file_exists(pck_path):
		if ProjectSettings.load_resource_pack(pck_path):
			print("DLC成功載入: %s" % pck_name)
		else:
			print("DLC載入失敗: %s" % pck_name)
	
