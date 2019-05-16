extends Node

class_name RoundsBase

enum round_status { PLAYING, CELEBRATING }
enum round_end_type { WIN, DRAW }
export var team_score = {}
export var current_round_status = round_status.CELEBRATING
export var total_rounds_played = 0
#{
#   type: round_end_type
#   winner_team?: int
#}
export var last_round_finish_info = {}
signal round_status_changed(new_round_status)

func _ready():
	for key in Globals.teams:
		team_score[key] = 0
	if get_tree().is_network_server():
		start_new_round()

func finish_round(winner_team: int):
	assert(get_tree().is_network_server())
	var type = round_end_type.DRAW if winner_team == -1 else round_end_type.WIN
	var finish_info = {
		"type": type,
	}
	if type != round_end_type.DRAW:
		finish_info["winner_team"] = winner_team
		team_score[winner_team] += 1
	rpc("on_round_status_changed", round_status.CELEBRATING, team_score, finish_info)

func start_new_round():
	assert(get_tree().is_network_server())
	if current_round_status == round_status.CELEBRATING:
		rpc("on_round_status_changed", round_status.PLAYING, team_score, {})

sync func on_round_status_changed(new_round_status: int, new_team_score: Dictionary, round_finish_info: Dictionary):
	var is_new_round = false
	if new_round_status != current_round_status:
		current_round_status = new_round_status
		if new_round_status == round_status.PLAYING:
			is_new_round = true
		if new_round_status == round_status.CELEBRATING:
			last_round_finish_info = round_finish_info
			total_rounds_played += 1
		emit_signal("round_status_changed", new_round_status)
	team_score = new_team_score
	if is_new_round:
		Globals.get_scene_as_game().get_logic().init_round()
