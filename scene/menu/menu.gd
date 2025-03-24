extends Control
class_name MenuScene

var select_rooms = []
var category_data: Main.CategoryData
var btns = []
var newTween:Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	$lightMask.mouse_filter = MOUSE_FILTER_IGNORE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup():
	select_rooms.append($SelectRoom)
	select_rooms.append($SelectRoom2)
	select_rooms.append($SelectRoom3)
	select_rooms.append($SelectRoom4)
	select_rooms.append($SelectRoom5)
	btns.append($MenuBtn)
	btns.append($MenuBtn2)
	btns.append($MenuBtn3)
	btns.append($MenuBtn4)
	btns.append($MenuBtn5)
	var i = 0
	for tr: TextureRect in select_rooms:
		tr.modulate.a = 0		
	for btn: MenuBtn in btns:				
		btn.mouse_entered.connect(_on_btn_mouse_entered.bind(i, btn))
		btn.mouse_exited.connect(_on_btn_mouse_exited.bind(i))
		btn.pressed.connect(_on_characters_btn_pressed.bind(i,btn))
		i += 1
		
	refresh()


func set_btns():
	var i = 0
	var temp_btn: MenuBtn = MenuBtn.new()
	for btn: MenuBtn in btns:
		var c_data = category_data.characters[i]
		btn.set_data(c_data)
		if i == 0:
			btn.open()
		else:
			if temp_btn.has_bonus:
				btn.open()
			else:
				btn.lock()
		temp_btn = btn
		i += 1


func refresh():
	category_data = Main.current_category_data
	$lightMask.color.a= 0
	for btn: MenuBtn in btns:		
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		
	set_btns()


func show_scene():	
	refresh()


func _on_btn_mouse_entered(id, btn) -> void:
	if btn.disabled	:
		return
	var tex:TextureRect= select_rooms[id] 	
	tex.modulate.a=0
	newTween = create_tween()	
	newTween.tween_property(
		tex,"modulate:a",0.6,0.15
	)

func _on_btn_mouse_exited(id) -> void:
	#select_rooms[id].visible = false
	var tex:TextureRect= select_rooms[id] 
	tex.modulate.a=0
	if newTween!=null:
		newTween.stop()


func _on_setting_button_pressed() -> void:
	Main.show_setting_view()


func _on_return_button_pressed() -> void:
	Main.to_scene(Main.SCENE.category)


func _on_characters_btn_pressed(i,btn) -> void:
	Main.current_character_data = btn.character_data	
	for b: MenuBtn in btns:
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex:TextureRect= select_rooms[i] 
	tex.modulate.a=0.6
	var newTween = create_tween()
	newTween.tween_property(
		tex,"modulate:a",2,0.3
	)
	newTween.tween_property(
		$lightMask,"color:a",1,0.6
	)
	newTween.finished.connect(_on_change_scene)
	
	
func _on_change_scene ():
	
	Main.to_scene(Main.SCENE.game)	
	
