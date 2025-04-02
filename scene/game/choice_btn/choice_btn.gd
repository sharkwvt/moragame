extends Button

enum CHOICES {
	剪刀,
	石頭,
	布
}

var choice: CHOICES
var bg: TextureRect
var hand: TextureRect

var tween: Tween
var pos: Vector2
var org_pos: Vector2
var selected_pos: Vector2
var is_bot: bool

var img_n = load("res://scene/game/choice_btn/select_bg.png")
var img_s = load("res://scene/game/choice_btn/select_bg_s.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pos = position
	org_pos = hand.position
	org_pos.y += 80
	selected_pos = hand.position
	hand.position = org_pos


func setup(c: CHOICES, bot: bool = false):
	bg = $BG
	hand = $TextureRect
	choice = c
	var img_path = "res://scene/game/choice_btn/"
	match choice:
		CHOICES.剪刀:
			img_path += "scissors_a.png"
		CHOICES.石頭:
			img_path += "rock_a.png"
		CHOICES.布:
			img_path += "paper_a.png"
	hand.texture = load(img_path)
	hand.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	is_bot = bot
	if is_bot:
		bg.texture = load("res://scene/game/choice_btn/npc_select_bg.png")
		bg.flip_v = true
		disabled = true

func hand_up():
	if not is_bot:
		bg.texture = img_s
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(hand, "position", selected_pos, 0.2)


func hand_down():
	if not is_bot:
		bg.texture = img_n
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(hand, "position", org_pos, 0.1)


func reset():
	hand.position = org_pos


func _on_mouse_entered() -> void:
	if disabled:
		return
	hand_up()


func _on_mouse_exited() -> void:
	if disabled:
		return
	hand_down()
