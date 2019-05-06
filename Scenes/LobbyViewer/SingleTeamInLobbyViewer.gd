extends VBoxContainer

var my_team_id: int
var team_members = []

func _ready():
	Globals.connect("player_info_changed", self, "player_info_changed")

func setup(team_id: int):
	$HBoxContainer/TeamNameLabel.text = Globals.teams[team_id].name
	my_team_id = team_id
	$HBoxContainer/MaxMembersLabel.text = str(Globals.teams[team_id].max_size)
	player_info_changed(Globals.player_info)
	
func player_info_changed(new_player_info):
	$MemberList.clear()
	team_members.clear()
	for single_player_id in new_player_info:
		if new_player_info[single_player_id].has('team') and new_player_info[single_player_id].team == my_team_id:
			$MemberList.add_item(new_player_info[single_player_id].player_name)
			team_members.append(single_player_id)
	$HBoxContainer/MemberCountLabel.text = str(len(team_members))
