extends ColorRect
class_name DialogView

var bg: NinePatchRect
var title: Label
var msg: Label
var confirm_btn: Button
var cancel_btn: Button

func setup():
	bg = $BG
	title = $BG/TitleLabel
	msg = $BG/MsgLabel
	confirm_btn = $BG/ConfirmButton
	cancel_btn = $BG/CancelButton
