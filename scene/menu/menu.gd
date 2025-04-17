extends Scene
class_name MenuScene

var show_unlock_anim: bool
var menus = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()


func refresh():
	for c: Control in get_children():
		c.visible = false

	var data: CategoryData = Main.current_category_data
	var node: Control
	if data.category in menus.keys():
		node = menus[data.category]
	else:
		node = data.menu.instantiate()
		add_child(node)
		menus[data.category] = node
	node.visible = true
	node.show_unlock_anim = show_unlock_anim
	node.refresh()
	show_unlock_anim = false # 只播放一次


func show_scene():
	refresh()

func return_scene():
	Main.to_scene(Main.SCENE.category)
