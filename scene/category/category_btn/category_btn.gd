extends Button

var texture_n: Texture
var texture_light: Texture
var texture_halo: Texture
var img_light: TextureRect
var img_halo: TextureRect
var tween: Tween
var is_lock: bool
var on_exit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func set_data(data: Main.CategoryData):
	on_exit = false
	$Panel/TitleLabel.text = data.category
	$Panel/ProgressLabel.text = data.get_progress_str()
	img_light = $LightImg
	img_halo = $Halo
	icon = texture_n
	img_light.texture = texture_light
	img_halo.texture = texture_halo
	
	img_light.modulate.a = 0
	
	await $Panel/ProgressLabel.minimum_size_changed # 大小有變更
	$Panel.size = $Panel/TitleLabel.size
	$Panel.size.x += 20
	$Panel.position.x = (size.x - $Panel.size.x)/2.0
	$Panel/ProgressLabel.position.y = $Panel.size.y


func _on_mouse_entered():
	if is_lock:
		return
	img_halo.visible = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(img_light, "modulate:a", 1, 1)
	tween.finished.connect(tween.kill)


func _on_mouse_exited():
	img_halo.visible = false
	if tween:
		tween.kill()
	img_light.modulate.a = 1 if on_exit else 0


func _on_button_down() -> void:
	Main.play_btn_sfx()
	on_exit = true
