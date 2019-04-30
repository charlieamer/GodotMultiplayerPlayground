extends Control

func create_room(game_type):
	var err = Globals.create_game(game_type, 1234)
	show_error_if_appropriate(err)

func join_room(ip: String, port: int):
	var err = Globals.join_game(ip, port)
	if show_error_if_appropriate(err):
		Globals.show_waiting_dialog(err)
		err = yield(Globals, "client_connecting_finished")
		show_error_if_appropriate(err)

#returns true if everything is ok
func show_error_if_appropriate(err) -> bool:
	if err is String and err != "":
		$AcceptDialog.dialog_text = err
		$AcceptDialog.popup_centered()
		return false
	else:
		return true
