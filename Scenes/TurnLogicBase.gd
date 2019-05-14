extends Node

sync var current_team_id: int

enum turn_result { PLAY_NEXT, DONT_PLAY_NEXT, WIN }

func _ready():
	current_team_id = Globals.teams.keys()[0]
	
func set_play_next_team():
	var current_team_key_index = Globals.teams.keys().find(current_team_id)
	var next_key = Globals.teams.keys()[(current_team_key_index + 1) % len(Globals.teams)]
	rpc("on_next_team_plays", next_key)
	
func can_play_turn(data, player_id) -> bool:
	return Globals.player_info[player_id].team_id == current_team_id

sync func on_next_team_plays(next_team_id: int):
	current_team_id = next_team_id

master func try_play_turn(data):
	var player_id = get_tree().get_rpc_sender_id() if get_tree().is_network_server() else get_tree().get_network_unique_id()
	if can_play_turn(data, player_id):
		if not get_tree().is_network_server():
			rpc("try_play_turn", data)
		else:
			var play_result = do_play_turn(data, player_id)
			if play_result.result == turn_result.PLAY_NEXT:
				set_play_next_team()

# returns: 
# {
#    result: turn_result
#    winner: int
# }
func do_play_turn(data, player_id: int):
	pass