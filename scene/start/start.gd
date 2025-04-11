extends Control
class_name StartScene

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.current_scene = self
	Main.instance_scenes[Main.SCENE.start] = self
	Main.play_music(Main.music_1)
	setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	var start_btn = $Control/StartButton
	start_btn.mouse_entered.connect(_on_mouse_entered.bind(start_btn))
	start_btn.mouse_exited.connect(_on_mouse_exited.bind(start_btn))
	var review_btn = $Control/ReviewButton
	review_btn.mouse_entered.connect(_on_mouse_entered.bind(review_btn))
	review_btn.mouse_exited.connect(_on_mouse_exited.bind(review_btn))
	var setting_btn = $Control/SettingButton
	setting_btn.mouse_entered.connect(_on_mouse_entered.bind(setting_btn))
	setting_btn.mouse_exited.connect(_on_mouse_exited.bind(setting_btn))
	var exit_btn = $Control/ExitButton
	exit_btn.mouse_entered.connect(_on_mouse_entered.bind(exit_btn))
	exit_btn.mouse_exited.connect(_on_mouse_exited.bind(exit_btn))
	var backgroundAni: SpineAnimationState = $SpineBG/SpineSprite.get_animation_state()
	backgroundAni.set_animation("title")


func play_click_anim(obj):
	var duration = 0.2
	tween.kill()
	tween = obj.create_tween()
	tween.tween_property(obj, "scale", Vector2(1.5, 1.5), duration)

func play_reset_anim(obj):
	var duration = 0.2
	tween.kill()
	tween = obj.create_tween()
	tween.tween_property(obj, "scale", Vector2(1, 1), duration)


func show_scene():
	pass




func _on_mouse_entered(btn: Button):
	var duration = 0.5
	if tween:
		tween.kill()
	tween = btn.create_tween()
	tween.set_loops()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), duration)
	tween.tween_property(btn, "scale", Vector2(1, 1), duration)

func _on_mouse_exited(btn: Button):
	btn.scale = Vector2(1, 1)
	if tween:
		tween.kill()

func _on_start_button_pressed() -> void:
	var btn = $Control/StartButton
	play_click_anim(btn)
	#await get_tree().create_timer(0.3).timeout
	await tween.finished
	Main.to_scene(Main.SCENE.category)
	play_reset_anim(btn)


func _on_review_button_pressed() -> void:
	var btn = $Control/ReviewButton
	play_click_anim(btn)
	await tween.finished
	Main.to_scene(Main.SCENE.review)
	play_reset_anim(btn)


func _on_setting_button_pressed() -> void:
	var btn = $Control/SettingButton
	play_click_anim(btn)
	await tween.finished
	Main.show_setting_view()
	play_reset_anim(btn)


func _on_exit_pressed() -> void:
	var btn = $Control/ExitButton
	play_click_anim(btn)
	await tween.finished
	get_tree().quit()
