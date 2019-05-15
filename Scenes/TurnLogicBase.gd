extends Node

sync var current_team_id: int
signal team_play_change(new_team_id)

enum turn_result { PLAY_NEXT, DONT_PLAY_NEXT, WIN }

func _ready():
	assert(get_game() != null)
	init_round()
	set_play_team(Globals.teams.keys()[0])
	
func set_play_next_team():
	var current_team_key_index = Globals.teams.keys().find(current_team_id)
	var next_key = Globals.teams.keys()[(current_team_key_index + 1) % len(Globals.teams)]
	set_play_team(next_key)
	
func set_play_team(team_id):
	if get_tree().is_network_server():
		rpc("on_next_team_plays", team_id)
	else:
		on_next_team_plays(team_id)
	
func can_play_turn(data, player_id: int) -> bool:
	return Globals.player_info[player_id].team == current_team_id

sync func on_next_team_plays(next_team_id: int):
	current_team_id = next_team_id
	emit_signal("team_play_change", next_team_id)

master func try_play_turn(data):
	var player_id = Globals.get_real_caller_player_id()
	print("Player: " + str(player_id) + " is playing turn: " + str(data))
	if can_play_turn(data, player_id):
		if not get_tree().is_network_server():
			rpc("try_play_turn", data)
		else:
			var play_result = do_play_turn(data, player_id)
			if play_result.result == turn_result.PLAY_NEXT:
				set_play_next_team()

sync func init_round():
	pass

func get_game() -> SceneBase:
	return get_parent() as SceneBase

# returns: 
# {
#    result: turn_result
#    winner_team: int
# }
func do_play_turn(data, player_id: int):
	pass