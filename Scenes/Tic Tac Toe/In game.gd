extends "res://Scenes/SceneBase.gd"

func _on_TurnLogic_team_play_change(new_team_id):
	var field_state = preload("res://Scenes/Tic Tac Toe/SingleField.gd").field_state
	var state_as_str = "X" if $Logic.playing_state[new_team_id] == field_state.X else "O"
	$CurrentPlayingLabel.text = Globals.get_team_name(new_team_id) + " plays as " + state_as_str
	$CurrentPlayingLabel.modulate = Globals.TeamColors[new_team_id]
