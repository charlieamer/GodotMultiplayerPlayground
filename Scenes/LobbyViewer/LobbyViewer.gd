extends Control

func _ready():
	for team_id in Globals.teams:
		var single_team_viewer = preload("./SingleTeamInLobbyViewer.tscn").instance()
		$CenterContainer/PanelContainer/HBoxContainer.add_child(single_team_viewer)
		single_team_viewer.setup(team_id)
	$CenterContainer/PanelContainer/HBoxContainer/VBoxContainer/StartGameButton.disabled = not get_tree().is_network_server()

func StartGamePressed():
	Globals.load_next_scene()
	
func DisconnectPressed():
	Globals.abort_game()