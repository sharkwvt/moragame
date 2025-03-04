extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Data.initialize_steam()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	Data.start_game()
