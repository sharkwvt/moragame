extends ButtonEx
class_name ReviewCGBtn

@export var image_view: TextureRect
@export var frame_view: TextureRect
@export var play_view: TextureRect
@export var lock_view: TextureRect
@export var dlc_view: TextureRect
@export var frame_img_photo: Texture
@export var frame_img_video: Texture

var is_lock = false
var is_video = false
var has_dlc = false

func refresh(img: Texture):
	image_view.texture = img
	image_view.visible = !is_lock
	play_view.visible = !is_lock and !img
	lock_view.visible = is_lock
	frame_view.texture = frame_img_video if is_video else frame_img_photo
	dlc_view.visible = is_video && !has_dlc
