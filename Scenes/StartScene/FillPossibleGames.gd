extends VBoxContainer

signal button_clicked(game_type)

func _ready():
	for child in get_children():
		remove_child(child)
	for game_type in Globals.Scenes:
		var btn: Button = Button.new()
		btn.text = game_type
		btn.connect("button_down", self, "on_button_clicked", [game_type])
		add_child(btn)

func on_button_clicked(game_type):
	emit_signal("button_clicked", game_type)