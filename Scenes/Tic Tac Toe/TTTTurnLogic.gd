extends TurnLogicBase

func _ready():
	pass

# team 0 -> O, team 1 -> X (flips at init round)
export var playing_state = [TTTSingleField.field_state.O, TTTSingleField.field_state.X]

sync func init_round():
	for child in get_node("../grid").get_children():
		child.set_state(TTTSingleField.field_state.NONE, -1)
	# flip who is playing which role
	for i in range(len(playing_state)):
		playing_state[i] = TTTSingleField.field_state.X if playing_state[i] == TTTSingleField.field_state.O\
			else TTTSingleField.field_state.O
	set_play_team(Globals.teams.keys()[Globals.get_scene_as_game().get_rounds().total_rounds_played % 2])

func get_field_by_number(field: int) -> TTTSingleField:
	return get_node("../grid/" + str(field)) as TTTSingleField

func get_board_value(field: int) -> int:
	return get_field_by_number(field).current_field_state

func is_winner(player_to_check: int) ->  bool:
    var test1 = (get_board_value(7) == player_to_check and get_board_value(8) == player_to_check and get_board_value(9) == player_to_check)
    var test2 = (get_board_value(4) == player_to_check and get_board_value(5) == player_to_check and get_board_value(6) == player_to_check)
    var test3 = (get_board_value(1) == player_to_check and get_board_value(2) == player_to_check and get_board_value(3) == player_to_check)
    var test4 = (get_board_value(7) == player_to_check and get_board_value(4) == player_to_check and get_board_value(1) == player_to_check)
    var test5 = (get_board_value(8) == player_to_check and get_board_value(5) == player_to_check and get_board_value(2) == player_to_check)
    var test6 = (get_board_value(9) == player_to_check and get_board_value(6) == player_to_check and get_board_value(3) == player_to_check)
    var test7 = (get_board_value(7) == player_to_check and get_board_value(5) == player_to_check and get_board_value(3) == player_to_check)
    var test8 = (get_board_value(9) == player_to_check and get_board_value(5) == player_to_check and get_board_value(1) == player_to_check)
    return test1 or test2 or test3 or test4 or test5 or test6 or test7 or test8

func is_draw() -> bool:
	return get_board_value(1) != TTTSingleField.field_state.NONE and\
			get_board_value(2) != TTTSingleField.field_state.NONE and\
			get_board_value(3) != TTTSingleField.field_state.NONE and\
			get_board_value(4) != TTTSingleField.field_state.NONE and\
			get_board_value(5) != TTTSingleField.field_state.NONE and\
			get_board_value(6) != TTTSingleField.field_state.NONE and\
			get_board_value(7) != TTTSingleField.field_state.NONE and\
			get_board_value(8) != TTTSingleField.field_state.NONE and\
			get_board_value(9) != TTTSingleField.field_state.NONE

func do_play_turn(field: int, player_id: int):
	var new_field_state = playing_state[current_team_id]
	get_field_by_number(field).rpc("set_state", new_field_state, current_team_id)
	if is_winner(new_field_state):
		return {
			"result": turn_result.FINISH,
			"winner_team": current_team_id
		}
	if is_draw():
		return {
			"result": turn_result.FINISH,
			"winner_team": -1
		}
	return {
		"result": turn_result.PLAY_NEXT
	}

func can_play_turn(data: int, player_id: int):
	return .can_play_turn(data, player_id) and\
		get_field_by_number(data).current_field_state == TTTSingleField.field_state.NONE