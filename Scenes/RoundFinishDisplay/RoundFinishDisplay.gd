extends Control

func _ready():
	Globals.get_scene_as_game().get_rounds().connect("round_status_changed", self, "on_round_status_changed")
	visible = false
	$StartRoundButton.disabled = not get_tree().is_network_server()

func on_round_status_changed(new_round_status):
	if new_round_status == RoundsBase.round_status.PLAYING:
		visible = false
	elif new_round_status == RoundsBase.round_status.CELEBRATING:
		visible = true
		var finish_status = Globals.get_scene_as_game().get_rounds().last_round_finish_info
		if finish_status.type == RoundsBase.round_end_type.WIN:
			$PlayerWonLabel.text = Globals.get_team_name(finish_status.winner_team) + " won"
		elif finish_status.type == RoundsBase.round_end_type.DRAW:
			$PlayerWonLabel.text = "DRAW"

func _on_StartRoundButton_pressed():
	Globals.get_scene_as_game().get_rounds().start_new_round()
