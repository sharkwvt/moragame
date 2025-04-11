extends Node

var pck_path = "res://pck_test.pck"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var success = ProjectSettings.load_resource_pack(pck_path, false)
	if success:
		print(pck_path + " 讀取成功")
