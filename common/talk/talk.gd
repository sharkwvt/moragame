extends TextureRect

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = $SubViewport.get_texture()


func show_talk_anim(text: String):
	visible = true
	var lbl: Label = $SubViewport/Label
	lbl.text = text
	$SubViewport.size.y = lbl.size.y
	size.y = lbl.size.y
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	position.y = Main.screen_size.y - size.y - 200
	modulate.a = 0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 100, 1)
	tween.tween_property(self, "modulate:a", 1, 1)
	tween.set_parallel(false)
	tween.tween_property(self, "modulate:a", 1, 1)
	tween.tween_property(self, "modulate:a", 0, 1)
