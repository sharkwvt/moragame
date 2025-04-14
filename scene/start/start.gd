extends Scene
class_name StartScene

var tween: Tween
var mask: ColorRect
var title: Control
var btns = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.current_scene = self
	Main.instance_scenes[Main.SCENE.start] = self
	Main.play_music(Main.music_1)
	setup()
	play_start_anim()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	mask = $Mask
	title = $Title
	btns.append($StartButton)
	btns.append($ReviewButton)
	btns.append($SettingButton)
	btns.append($ExitButton)
	for i in btns.size():
		var btn: Button = btns[i]
		btn.add_theme_color_override("font_disabled_color", Color.WHITE)
		btn.mouse_entered.connect(_on_mouse_entered.bind(i))
		btn.mouse_exited.connect(_on_mouse_exited.bind(i))
		btn.pressed.connect(_on_button_pressed.bind(i))
		btn.modulate.a = 0

	# 背景動畫
	var backgroundAni: SpineAnimationState = $SpineBG/SpineSprite.get_animation_state()
	backgroundAni.set_animation("title")


func play_start_anim():
	title.modulate.a = 0
	tween = create_tween()
	var title_center =  Vector2(title.position.x, size.y/2.0 - title.size.y/2.0)
	tween.tween_method(title.set_position, title_center, title.position, 1)
	tween.parallel().tween_property(title, "modulate:a", 1, 1)
	tween.set_parallel()
	for i in btns.size():
		var btn: Button = btns[i]
		var delay = 0.5 + i*0.2
		tween.tween_method(btn.set_position, Vector2(0, btn.position.y), btn.position, 0.5).set_delay(delay)
		tween.tween_property(btn, "modulate:a", 1, 0.5).set_delay(delay)
	tween.finished.connect(func(): mask.visible = false) # 移除防點擊

func play_entered_anim(obj):
	var duration = 0.5
	tween.kill()
	tween = obj.create_tween()
	tween.set_loops()
	tween.tween_property(obj, "scale", Vector2(1.1, 1.1), duration)
	tween.tween_property(obj, "scale", Vector2(1, 1), duration)

func play_click_anim(obj):
	var duration = 0.2
	tween.kill()
	tween = obj.create_tween()
	tween.tween_property(obj, "scale", Vector2(1.5, 1.5), duration)
	tween.tween_property(obj, "scale", Vector2(1, 1), duration)


func reset_btns():
	if tween:
		tween.kill()
	for btn: Button in btns:
		btn.scale = Vector2(1, 1)
	
func set_btns_disabled(b: bool):
	for btn: Button in btns:
		btn.disabled = b


func _on_mouse_entered(i):
	play_entered_anim(btns[i])

func _on_mouse_exited(i):
	reset_btns()
	set_btns_disabled(false)

func _on_button_pressed(i) -> void:
	set_btns_disabled(true)
	var btn: Button = btns[i]
	play_click_anim(btn)
	await tween.finished
	match i:
		0:
			Main.to_scene(Main.SCENE.category)
		1:
			Main.to_scene(Main.SCENE.review)
		2:
			Main.show_setting_view()
		3:
			get_tree().quit()
	set_btns_disabled(false)
