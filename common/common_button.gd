extends Button
class_name CommonButton

var btn_sfx = preload("res://sound/maou_se_system47.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(_on_button_down)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_down() -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = btn_sfx
	audio_player.bus = "SFX"
	audio_player.finished.connect(_on_sfx_finished.bind(audio_player))
	get_tree().root.add_child(audio_player)
	audio_player.play()


func _on_sfx_finished(audio_player: AudioStreamPlayer):
	audio_player.queue_free()
