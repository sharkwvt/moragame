extends Button

var img_n
var img_s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func set_data(data: Main.CategoryData):
	$Panel/TitleLabel.text = data.category
	$Panel/ProgressLabel.text = data.get_progress_str()
	await $Panel/ProgressLabel.minimum_size_changed
	$Panel.size = $Panel/TitleLabel.size
	$Panel.size.x += 20
	$Panel.position.x = (size.x - $Panel.size.x)/2.0
	$Panel/ProgressLabel.position.y = $Panel.size.y


func _on_mouse_entered():
	icon = img_s


func _on_mouse_exited():
	icon = img_n


func _on_button_down() -> void:
	Main.play_btn_sfx()
