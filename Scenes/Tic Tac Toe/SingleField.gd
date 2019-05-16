extends Area2D

enum field_state { X, O, NONE }

class_name TTTSingleField

func _ready():
	pass

export var current_field_state = field_state.NONE
var played_by_team: int

sync func set_state(new_state: int, team_id: int):
	if new_state == field_state.X:
		$O.visible = false
		$X.visible = true
		$X.modulate = Globals.TeamColors[team_id]
	if new_state == field_state.O:
		$O.visible = true
		$X.visible = false
		$O.modulate = Globals.TeamColors[team_id]
	if new_state == field_state.NONE:
		$O.visible = false
		$X.visible = false
	played_by_team = team_id
	current_field_state = new_state

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		Globals.get_scene_as_game().get_logic().try_play_turn(get_name().to_int())