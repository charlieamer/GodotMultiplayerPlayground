extends Node

# Key is name of game
# Value is array of possible scenes for the game, where the first scene is the
#   default one. The way to get scene resource is res://Scenes/[GameName]/[SceneName].tscn
export var Scenes = {
	"Tic Tac Toe": ["Lobby", "In game"]
}
export var CurrentSceneIndex = -1
export var CurrentGame = ""
export var TeamColors = [Color("#2ecc71"), Color("#e74c3c")]

signal scene_is_ready()

signal client_connecting_finished(error)
signal player_info_changed(new_player_info)

# network_id: {
#     player_name -> String
#     team?: -> Integer
# }
export var player_info = {}
# team_id: {
#     name -> String
#     max_size -> Integer
# }
export var teams = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
    pass

func _player_disconnected(id):
	get_scene_as_game().on_player_left(id, player_info[id])
	player_info.erase(id)
	all_player_info_updated(player_info)

func _connected_ok():
	rpc_id(1, "server_got_player_info", {
		"player_name": "client"
	})

func _server_disconnected():
	client_kicked(false, "Server disconnected")

func _connected_fail():
	emit_signal("client_connecting_finished", "Connection failed")
	
func abort_game():
	client_kicked(false, "")
	
remote func client_kicked(at_join_time: bool, reason: String):
	if at_join_time:
		emit_signal("client_connecting_finished", "Kicked: " + reason)
	else:
		get_tree().change_scene("res://Scenes/StartScene/StartScene.tscn")
	get_tree().set_network_peer(null)

func get_scene_as_game() -> SceneBase:
	if get_tree().current_scene is SceneBase:
		return get_tree().current_scene as SceneBase
	else:
		return null
		
func setup_teams(new_teams: Dictionary):
	teams = new_teams
	#for player_id in player_info:
	#	try_transfer_player_to_team(player_id, new_teams.keys()[0])

func try_transfer_player_to_team(player_id, team_id, update_clients = false) -> String:
	if not teams.has(team_id):
		return "Team " + str(team_id) + " doesn't exist"
	if not player_info.has(player_id):
		return "Player " + str(player_id) + " doesn't exist"
	if len(get_players_in_team(team_id)) >= teams[team_id].max_size:
		return "Team is full"
	player_info[player_id].team = team_id
	if (update_clients):
		rpc("all_player_info_updated", player_info)
	return ""
	
func get_players_in_team(team_id):
	var ret = []
	for player_id in player_info:
		if player_info[player_id].has('team') and player_info[player_id].team == team_id:
			ret.append(player_id)
	return ret
	
sync func all_player_info_updated(new_player_info):
	player_info = new_player_info
	print("Player info changed: " + str(player_info))
	emit_signal("player_info_changed", player_info)

remote func client_player_confirmed(all_players_info, current_game_id: String, current_scene_id: int):
	emit_signal("client_connecting_finished", "")
	if not get_tree().is_network_server():
		print("Successfuly connected to server. There are " + str(len(all_players_info.keys())) + " connected players")
		print("Currently playing: " + current_game_id + " (" + Scenes[current_game_id][current_scene_id] + ")")
		CurrentGame = current_game_id
		change_scene(current_scene_id)
	all_player_info_updated(all_players_info)
	
remote func server_got_player_info(single_player_info, use_rpcs = true):
	if not get_tree().is_network_server():
		return
	var new_player_network_id = get_tree().get_rpc_sender_id() if use_rpcs else 1
	player_info[new_player_network_id] = single_player_info
	print("New player connected: " + single_player_info.player_name)
	var join_error = get_scene_as_game().on_player_joined(new_player_network_id, single_player_info)
	if not is_okay(join_error):
		print("But it is kicked because: " + join_error)
		rpc_id(new_player_network_id, "client_kicked", true, join_error)
		player_info.erase(new_player_network_id)
		return
	if use_rpcs:
		rpc_id(get_tree().get_rpc_sender_id(), "client_player_confirmed", player_info, CurrentGame, CurrentSceneIndex)
		rpc("all_player_info_updated", player_info)
	else:
		client_player_confirmed(player_info, CurrentGame, 0)

func get_game_scene_path(game_name: String, extension: String, index: int) -> String:
	return "res://Scenes/" + game_name + "/" + Scenes[game_name][index] + "." + extension
	
func load_next_scene():
	rpc("change_scene", ((CurrentSceneIndex + 1) % len(Scenes[CurrentGame])))

sync func change_scene(new_scene_number: int):
	CurrentSceneIndex = new_scene_number
	var err = get_tree().change_scene(get_game_scene_path(CurrentGame, "tscn", new_scene_number))
	if err != OK:
		print("Error changing scene: " + err)
	yield(self, "scene_is_ready")

func create_game(game_name: String, port: int) -> String:
	if Scenes.has(game_name):
		var game_scene : SceneBase = load(get_game_scene_path(game_name, "gd", 0)).new()
		var peer = NetworkedMultiplayerENet.new()
		var err = peer.create_server(port, 10)
		if (err == ERR_ALREADY_IN_USE):
			return "Port already in use"
		if (err == ERR_CANT_CREATE):
			return "Can't create server"
		if (err != OK):
			return "Unknown error"
		get_tree().set_network_peer(peer)
		
		# change scene
		CurrentGame = game_name
		yield(change_scene(0), "completed")
		server_got_player_info({"player_name": "server"}, false)
		
		return ""
	return "Game " + game_name + " doesn't exist"

func join_game(ip: String, port: int):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	if err == ERR_CANT_CREATE:
		return "Can't create connection"
	if err != OK:
		return "Unknown error"
	yield(self, "client_connecting_finished")

func show_waiting_dialog(coroutine: GDScriptFunctionState):
	var popup = preload("res://Scenes/WaitingDialog/WaitingDialog.tscn").instance()
	get_tree().root.add_child(popup)
	return popup.setup(coroutine)
	
func is_okay(err):
	return err is String and err == ""

func register_scene_loaded():
	emit_signal("scene_is_ready")

func get_real_caller_player_id():
	var player_id = get_tree().get_rpc_sender_id() if get_tree().is_network_server() else get_tree().get_network_unique_id()
	if player_id == 0:
		player_id = 1
	return player_id

func get_team_name(team_id: int) -> String:
	var players_in_team = get_players_in_team(team_id)
	if len(players_in_team) == 1:
		return player_info[players_in_team[0]].player_name
	else:
		return teams[team_id].name