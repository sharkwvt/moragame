extends Button
class_name CategoryBtn

@export var img_light: TextureRect
@export var img_halo: TextureRect
@export var shader: Shader

signal show_info
signal hide_info

var texture_n: Texture
var texture_light: Texture
var texture_halo: Texture
var c_data: CategoryData
var tween: Tween
var is_lock: bool
var on_exit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func set_data(data: CategoryData):
	c_data = data
	on_exit = false
	$Panel/TitleLabel.text = data.category_title
	$Panel/ProgressLabel.text = data.get_progress_str()
	img_light.texture = texture_light
	img_halo.texture = texture_halo
	var mt = ShaderMaterial.new()
	mt.shader = shader
	img_light.material = mt
	
	#img_light.modulate.a = 0
	img_halo.visible = false
	#img_light.visible = false
	#set_light_progress(0.0)
	
	await $Panel/ProgressLabel.minimum_size_changed # 大小有變更
	$Panel.size = $Panel/TitleLabel.size
	$Panel.size.x += 20
	$Panel.position.x = (size.x - $Panel.size.x)/2.0
	$Panel/ProgressLabel.position.y = $Panel.size.y


func refresh_light_progress():
	var progress = 0.3 + c_data.progress / c_data.all_level * 0.7
	if is_lock:
		progress = 0
	set_light_progress(progress)

func set_light_progress(progress: float):
	img_light.material.set_shader_parameter("progress", progress)


func _on_mouse_entered():
	show_info.emit()
	#if is_lock:
		#return
	img_halo.visible = true
	img_light.visible = true
	#if tween:
		#tween.kill()
	#set_light_progress(0.0)
	#tween = create_tween()
	#tween.tween_property(img_light, "modulate:a", 1, 1)
	#var count: float = 3
	#for i in count:
		#tween.tween_callback(func(): set_light_progress((i+1) * (1/count)))
		#tween.tween_interval(1/count)
	#tween.finished.connect(tween.kill)


func _on_mouse_exited():
	img_halo.visible = false
	hide_info.emit()
	#if tween:
		#tween.kill()
	#img_light.modulate.a = 1 if on_exit else 0
	#img_light.visible = on_exit
	#set_light_progress(1 if on_exit else 0)


func _on_button_down() -> void:
	Main.play_btn_sfx()
	on_exit = true
