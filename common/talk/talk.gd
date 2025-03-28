extends TextureRect

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = $SubViewport.get_texture()


func show_talk_anim(text: String):
	# 初始化
	visible = true
	modulate.a = 0
	var lbl: Label = $SubViewport/Label
	lbl.text = text
	if tween:
		tween.kill()
	tween = create_tween()
	
	# 在下一幀後才會更新size
	await get_tree().process_frame
	$SubViewport.size.y = lbl.size.y
	size.y = lbl.size.y
	position.y = Main.screen_size.y - size.y - 200
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 50, 1)
	tween.tween_property(self, "modulate:a", 1, 1)
	tween.set_parallel(false)
	tween.tween_property(self, "modulate:a", 1, 1)
	tween.tween_property(self, "modulate:a", 0, 1)
