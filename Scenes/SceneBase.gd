extends Node

class_name SceneBase

export onready var GameTypeName = get_script().get_path().split('/')[3]
export onready var SceneName = get_script().get_path().split('/')[4].trim_suffix(".gd")

func _ready():
	pass

func on_player_joined(new_player_id, new_player_info):
	return ""