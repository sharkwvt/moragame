extends Object
class_name TalkData

var start_strs = []
var lose_strs = []
var win_strs = []
var pass_strs = []

func get_start_strs() -> String:
	return start_strs.pick_random()

func get_lose_str() -> String:
	return lose_strs.pick_random()

func get_win_str() -> String:
	return win_strs.pick_random()

func get_pass_str() -> String:
	return pass_strs.pick_random()
