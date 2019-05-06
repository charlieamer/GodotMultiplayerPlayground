extends SceneBase

func _enter_tree():
	Globals.setup_teams({
		0: {
			"name": "Player 1",
			"max_size": 1
		},
		1: {
			"name": "Player 2",
			"max_size": 1
		}
	})

