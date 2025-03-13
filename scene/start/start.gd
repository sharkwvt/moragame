extends Control
class_name StartScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.current_scene = self
	Main.instance_scenes[Main.SCENE.start] = self
	Main.play_music(Main.music_1)	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func show_scene():
	pass


func run_spine_start():
	var bellaAnim: SpineAnimationState = $ColorRect/bella.get_animation_state()
	bellaAnim.set_time_scale(2)
	for element in (($ColorRect/bella.skeleton_data_res as SpineSkeletonDataResource).get_animations() as Array[SpineAnimation]) :
		bellaAnim.add_animation((element as SpineAnimation).get_name(),0,false,0)
	
func run_spine_stop():
	var anim: SpineAnimationState = $ColorRect/bella.get_animation_state()
	anim.clear_tracks()


func _on_start_button_pressed() -> void:
	Main.to_scene(Main.SCENE.menu, 1)


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_結束_pressed() -> void:
	get_tree().quit()


func _on_test_button_pressed() -> void:
	$ColorRect.visible=true
	run_spine_start()


func _on_close_test_button_pressed() -> void:
	$ColorRect.visible=false
	run_spine_stop()
