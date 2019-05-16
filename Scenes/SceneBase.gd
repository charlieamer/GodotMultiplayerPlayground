extends Node

class_name SceneBase

export onready var GameTypeName = get_script().get_path().split('/')[3]
export onready var SceneName = get_script().get_path().split('/')[4].trim_suffix(".gd")

func _ready():
	if not get_tree().is_network_server():
		remove_child($ServerListener)
	Globals.register_scene_loaded()

func on_player_joined(new_player_id, new_player_info):
	if $ServerListener != null and $ServerListener.has_method("on_player_joined"):
		return $ServerListener.on_player_joined(new_player_id, new_player_info)
	return ""
	
func on_player_left(old_player_id, old_player_info):
	pass

func get_logic() -> LogicBase:
	return $Logic as LogicBase

func get_rounds() -> RoundsBase:
	return $Rounds as RoundsBase