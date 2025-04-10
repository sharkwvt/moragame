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
	var start_btn = $StartButton
	start_btn.mouse_entered.connect(_on_mouse_entered.bind(start_btn))
	start_btn.mouse_exited.connect(_on_mouse_exited.bind(start_btn))
	var review_btn = $ReviewButton
	review_btn.mouse_entered.connect(_on_mouse_entered.bind(review_btn))
	review_btn.mouse_exited.connect(_on_mouse_exited.bind(review_btn))
	var setting_btn = $SettingButton
	setting_btn.mouse_entered.connect(_on_mouse_entered.bind(setting_btn))
	setting_btn.mouse_exited.connect(_on_mouse_exited.bind(setting_btn))
	var exit_btn = $ExitButton
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


func run_spine_start():
	var bellaAnim: SpineAnimationState = $ColorRect/bella.get_animation_state()
	bellaAnim.set_time_scale(2)
	for element in (($ColorRect/bella.skeleton_data_res as SpineSkeletonDataResource).get_animations() as Array[SpineAnimation]) :
		bellaAnim.add_animation((element as SpineAnimation).get_name(),0,false,0)
	
	var wendyAnim: SpineAnimationState = $ColorRect/wendy.get_animation_state()
	wendyAnim.set_time_scale(2)
	for element in (($ColorRect/wendy.skeleton_data_res as SpineSkeletonDataResource).get_animations() as Array[SpineAnimation]) :
		wendyAnim.add_animation((element as SpineAnimation).get_name(),0,false,0)
	
	var lolaAnim: SpineAnimationState = $ColorRect/lola.get_animation_state()
	lolaAnim.set_time_scale(2)
	for element in (($ColorRect/lola.skeleton_data_res as SpineSkeletonDataResource).get_animations() as Array[SpineAnimation]) :
		lolaAnim.add_animation((element as SpineAnimation).get_name(),0,false,0)
	
	var kittyAnim: SpineAnimationState = $ColorRect/kitty.get_animation_state()
	kittyAnim.set_time_scale(2)
	for element in (($ColorRect/kitty.skeleton_data_res as SpineSkeletonDataResource).get_animations() as Array[SpineAnimation]) :
		kittyAnim.add_animation((element as SpineAnimation).get_name(),0,false,0)
	
func run_spine_stop():
	var anim1: SpineAnimationState = $ColorRect/bella.get_animation_state()
	anim1.clear_tracks()
	var anim2: SpineAnimationState = $ColorRect/wendy.get_animation_state()
	anim2.clear_tracks()
	var anim3: SpineAnimationState = $ColorRect/kitty.get_animation_state()
	anim3.clear_tracks()
	var anim4: SpineAnimationState = $ColorRect/lola.get_animation_state()
	anim4.clear_tracks()


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
	var btn = $StartButton
	play_click_anim(btn)
	#await get_tree().create_timer(0.3).timeout
	await tween.finished
	Main.to_scene(Main.SCENE.category)
	play_reset_anim(btn)


func _on_review_button_pressed() -> void:
	var btn = $ReviewButton
	play_click_anim(btn)
	await tween.finished
	Main.to_scene(Main.SCENE.review)
	play_reset_anim(btn)


func _on_setting_button_pressed() -> void:
	var btn = $SettingButton
	play_click_anim(btn)
	await tween.finished
	Main.show_setting_view()
	play_reset_anim(btn)


func _on_exit_pressed() -> void:
	var btn = $ExitButton
	play_click_anim(btn)
	await tween.finished
	get_tree().quit()


func _on_test_button_pressed() -> void:
	$ColorRect.visible=true
	run_spine_start()


func _on_close_test_button_pressed() -> void:
	$ColorRect.visible=false
	run_spine_stop()
