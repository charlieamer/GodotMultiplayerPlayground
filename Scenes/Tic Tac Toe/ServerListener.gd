extends Node

func _ready():
	pass

func on_player_joined(new_player_id, new_player_info):
	if not new_player_info.has('team'):
		if not Globals.is_okay(Globals.try_transfer_player_to_team(new_player_id, 0)):
			if not Globals.is_okay(Globals.try_transfer_player_to_team(new_player_id, 1)):
				return "No available teams to join"
	return ""