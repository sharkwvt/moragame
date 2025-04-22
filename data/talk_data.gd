extends Object
class_name TalkData

var lose_strs = []
var win_strs = []
var pass_strs = []

func get_lose_str() -> String:
	return lose_strs[randi_range(0, lose_strs.size()-1)]

func get_win_str() -> String:
	return win_strs[randi_range(0, win_strs.size()-1)]

func get_pass_str() -> String:
	return pass_strs[randi_range(0, pass_strs.size()-1)]
