extends SceneBase

func _ready():
	Globals.setup_teams({
		0: {
			"name": "Player 1",
			"max_size": 1
		},
		1: {
			"name": "Player 2",
			"max_size": 1
		}
	})
	Globals.register_scene_loaded()
	
func on_player_joined(new_player_id, new_player_info):
	var err = .on_player_joined(new_player_id, new_player_info)
	if not Globals.is_okay(err):
		return err
	if not new_player_info.has('team'):
		if not Globals.is_okay(Globals.try_transfer_player_to_team(new_player_id, 0)):
			if not Globals.is_okay(Globals.try_transfer_player_to_team(new_player_id, 1)):
				return "No available teams to join"
	return ""