extends Node

var logs = []
var log_window: Window
var lbl: Label

func show_log():
	if log_window:
		return
	log_window = Window.new()
	log_window.title = "Log"
	log_window.size = Vector2(1000, 400)
	log_window.close_requested.connect(close)
	log_window.set_position(Vector2(100, 100))

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	log_window.add_child(scroll)

	lbl = Label.new()
	lbl.add_theme_font_size_override("font_size", 30)
	scroll.add_child(lbl)
	
	for line: String in logs:
		lbl.text += line + "\n"

	# 添加關閉按鈕
	#var close_button := Button.new()
	#close_button.text = "Close"
	#close_button.pressed.connect(close)
	#vbox.add_child(close_button)

	get_tree().get_root().add_child(log_window)
	log_window.popup_centered()

func refresh():
	if !lbl:
		return
	var s = ""
	for line: String in logs:
		s += line + "\n"
	lbl.text = s


func log(msg: String):
	print(msg)
	logs.append(msg)
	refresh()

func close():
	log_window.queue_free()
